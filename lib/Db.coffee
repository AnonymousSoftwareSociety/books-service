_db = require 'pg'
_   = require 'underscore'
inspect = require('util').inspect

module.exports = (options) -> 
	cli = new _db.Client(options)
	cli.connect()
	
	module.exports.query = (args...) =>
		[qs, params, callback, verbose] = args
		if verbose is undefined
			verbose = false
		callback = params if _.isFunction params
		rowsCallback = (err, result) -> 
			console.log 'Postgres error: #{err}' if err
			callback if not verbose then result.rows else result
		if _.isArray params then cli.query(qs, params, rowsCallback) else cli.query(qs, rowsCallback)
	
	module.exports.VERBOSE = true
	
	module.exports