_ = require 'underscore'



module.exports.compactFlash = (msgArray, cls = 'error') ->
	console.log JSON.stringify(msgArray)
	('<p class="{#cls}">' + msg + "</p>" for msg in msgArray).join('')
