db  = require __dirname + '/Db'
_   = require 'underscore'
sha = require 'sha1'

# return user by username

module.exports.getByUsername = (username, callback, includePwd = true) ->
	
	fields =  if includePwd then '*' else 'id,username,email'
	db.query("SELECT " + fields + " FROM users WHERE username = $1", 
		[username], (rows) => 
			console.log(JSON.stringify(rows))
			callback rows[0]
	)
	
# return user by id

module.exports.getById = (id, callback, includePwd = true) ->
	
	fields =  if includePwd then '*' else 'id,username,email'
	db.query("SELECT " + fields + " FROM users WHERE id = $1", 
		[id], (rows) => 
			console.log(JSON.stringify(rows))
			callback rows[0]
	)
	
checkRegistrationData = (req, res, callback) -> 
	console.log "check registration"
	checks = [((data) => 
		console.log "#{data.password} == #{data.password2}"
		ok = data.password == data.password2
		req.flash('error', "Le password digitate non corrispondono") if not ok
		ok
	),
	((data) => 
		ok = _.all(_.values(data), (value) -> value? && value != '')
		req.flash('error', "Valori mancanti") if not ok
		ok
	),
	((data) => 
		ok = /^[a-zA-Z_0-9\.\-]+@[a-zA-Z_0-9\.\-]+$/.test(data.email)
		req.flash('error', "Email non valida") if not ok
		ok
	)]
	data = req.body
	if _.all(checks, (check) => check data )
		callback(req, res)
	else
		return res.redirect('/register')

checkNoDup = (req, res, callback) ->
	=>
		data = req.body
		db.query("SELECT * FROM users WHERE username = $1 OR email = $2 ", 
			[data.username, data.email],
			(rows) => 
				if rows.length > 0
					req.flash('error', """Un utente con la stessa email 
					e/o username è già registrato!""" )
					res.redirect('/register')
				else
					callback(req, res)
		)

writeRegistrationData = (req, res, callback) => 
	=>
		data = req.body
		db.query("INSERT INTO users (username,email,password) VALUES ($1,$2,$3)",
			[data.username, data.email, sha(data.username + data.password)], ((result) =>
				db.query("SELECT id, username, email FROM users WHERE username = $1", [data.username],
					(users) => 
						callback(req, res, users[0])
				)
			)
		)
	
module.exports.register = (req, res) =>
	checkRegistrationData(req, res, 
		checkNoDup(req, res, 
			writeRegistrationData(req, res, 
				(req, res, user) -> req.login(user, -> res.redirect('/login')))))
