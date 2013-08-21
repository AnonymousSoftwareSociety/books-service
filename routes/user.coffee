
###
 GET users listing.
###

uCtl = require __dirname + '/../lib/UserController' 

exports.getUser = (req, res) -> uCtl.getByUsername(req.params.username, (obj) => res.json obj)