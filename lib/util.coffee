_ = require 'underscore'
db = require __dirname + '/Db'


module.exports.compactFlash = (msgArray, cls = 'error') ->
	console.log JSON.stringify(msgArray)
	('<p class="{#cls}">' + msg + "</p>" for msg in msgArray).join('')

	
module.exports.getClasses = (callback) =>
	db.query("""SELECT id, year || ' ' || section AS class FROM classes
""", (rows) => callback({ classes: rows }))