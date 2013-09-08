bsUtil = require __dirname + '/util'
_      = require 'underscore'
oCtl   = require __dirname + '/OfferController'
rCtl   = require __dirname + '/RequestController'
bCtl   = require __dirname + '/BookController'

###
 GET home page.
###

exports.index = (req, res) ->
  console.log ('RENDERING INDEX')
  res.render('index', { title: 'Books-service', user: req.user })

		
renderBooksSelection = (req, res) =>
	opts =
		action: "/#{req.body.actionType}/3"
		actionType: req.body.actionType
		class: req.body.class
	bCtl.getBooksByClass(req.body.class, (books) => 
		res.render('books_dialog', _.extend(books, opts))
	)

createObject = (req, res) =>
	type = req.params[0]
	console.log 'createObject'
	switch type
		when 'offer'   then oCtl.createOffer(req, res)
		when 'request' then rCtl.insertRequests(req, res)
		else return res.send(404)

exports.actionWizardStep = (req, res) =>
	step = parseInt(req.params[1], 10)
	console.log 'actionWizardStep'
	switch step
		when 2 then renderBooksSelection(req, res)
		when 3 then createObject(req, res)
		else return res.send(404)

# Set the kind of action we are performing
# and render first step of wizard accordingly
exports.actionWizardSwitch = (req, res) =>
	type = req.params[0]
	switch type
		when 'offer'   then verb = "vendere"
		when 'request' then verb = "acquistare"
		else
			return res.send(404)
	opts = { 
			actionLabel: """Scegli la classe di cui vuoi 
				#{verb} libri""",
			action: "/#{type}/2",
			actionType: "#{type}"
	}
	bsUtil.getClasses((classes) =>
		res.render('class_dialog', _.extend(classes, opts))
	)
	
