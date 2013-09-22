postmark = require 'postmark'
mustache = require 'mustache'
_        = require 'underscore'

# template for the mail SENT TO SELLER
sellerMailTpl =
"""
Ciao {{sell.username}},

abbiamo buone notizie per te: l'utente {{request.username}}
sta cercando il libro {{book.title}} che tu hai messo in vendita.
Puoi contattarlo all'indirizzo {{request.user.email}}

"""

# template for the mail SENT TO POTENTIAL BUYER
buyerMailTpl =
"""
Ciao {{request.username}},

abbiamo buone notizie per te: l'utente #{request.username}
ha messo in vendita il libro {{book.title}} che tu stai cercando.
Puoi contattarlo all'indirizzo {{sell.user.email}}

"""

common =
		From: "no-reply@bks.herokuapp.com"

module.exports.sendMails = (negotiationData) =>
	
	postmark.send(_.extend(common, {
		"To": negotiationData.request.user.email,
		Subject: "Il libro che stai cercando è in vendita",
		"TextBody": mustache.render(negotiationData, buyerMailTpl);
	});
	
	postmark.send(_.extend(common, {
		"To": negotiationData.sell.user.email,
		Subject: "Qualcuno cerca il libro che stai vendendo",
		"TextBody": mustache.render(negotiationData, sellerMailTpl);
	}));

