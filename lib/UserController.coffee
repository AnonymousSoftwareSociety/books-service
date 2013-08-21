db = require __dirname + '/Db'


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