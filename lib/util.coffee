_ = require 'underscore'



module.exports.compactFlash = (msgArray, cls = 'error') ->
	('<p class="{#cls}">' + msg + "</p>" for msg in msgArray).join('')
