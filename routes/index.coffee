
###
 GET home page.
###

exports.index = (req, res) ->
  console.log ('RENDERING INDEX')
  res.render('index', { title: 'Express', user: req.user })
