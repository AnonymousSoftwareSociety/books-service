_db = require 'pg'
_   = require 'underscore'

module.exports = (options) -> 
	cli = new _db.Client(options)
	cli.connect()
	
	module.exports.query = (args...) =>
		[qs, params, callback] = args
		callback = params if _.isFunction params
		rowsCallback = (err, result) -> 
			console.log('Postgres error: ' + err.toString()) if err
			callback result.rows
		if _.isArray params then cli.query(qs, params, rowsCallback) else cli.query(qs, rowsCallback)
	
	module.exports