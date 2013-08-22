sha1   = require 'sha1'
bsUtil = require __dirname + '/util'

module.exports.successRedirect = '/'

module.exports.check = (user, password) ->
	console.log (user.password + "==" + sha1(user.username + password))
	user.password == sha1(user.username + password)

module.exports.logout = (req, res) =>
	req.logout()
	req.redirect successRedirect

module.exports.ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect '/login'
  
module.exports.login = (req, res) => 
  res.render('loginForm', { message: bsUtil.compactFlash(req.flash('error')) })
