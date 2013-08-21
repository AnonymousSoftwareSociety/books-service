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
	
checkRegistrationData = (data, callback) => 
	checks = [(data) -> data.password == data.password2,
	(data) -> _.all(_.values(data), (value) -> value? && value != ''),
	(data) -> /^[a-zA-Z_0-9\.\-]+@[a-zA-Z_0-9\.\-]+$/.test(data.email)]
	if _.all(checks, (check) => check data )
		callback data
	else
		return res.render('error', { message: """Errore nei dati! 
	Controlla che tutti i campi siano stati compilati, le password 
corrispondano e l'email sia valida. 
 """ })

checkNoDup = (data, callback) ->
	db.query("SELECT * FROM users WHERE username = $1 OR email = $2 ", 
		[data.username, data.email],
		(rows) => 
			if rows.length > 0
				return res.render('error', { message: """Un utente con la stessa email 
				e/o username è già registrato!""" })
			else
				callback data
	)

writeRegistrationData = (data, callback) -> 
	db.query("INSERT INTO users (username,email,password) VALUES ($1,$2,$3)",
		[data.username, data.email, sha1(data.username + data.password)],
		callback
	)
	