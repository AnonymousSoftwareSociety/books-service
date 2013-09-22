db        = require __dirname + '/Db'
_         = require 'underscore'
asyncMap  = require('async').map;
util      = require __dirname + '/util'
sendMails = require(__dirname + '/MailHelper').sendMails

SUCCESS = true
FAILURE = false

checkMatchingExists = (table) =>
    (object, callback) => 
        console.log "checkMatchingExists on #{table}"
        db.query("""SELECT id FROM #{table} AS sl
                 WHERE sl."Books_id" = $1 AND 
                 sl."Statuses_id" = $2
                 ORDER BY sl.creation_date ASC
                 LIMIT 1 OFFSET 0""", [object.Books_id, util.status.OPEN],
                (rows) => 
                    console.log 'rows matching'
                    console.log JSON.stringify rows
                    if rows.length > 0 
                        callback(rows[0], object)
                    else 
                        callback(null, object))


checkNoDup = (table) =>
    (requestInfo, success, failure) =>
        console.log "checkNoDup on #{table}"
        db.query("""SELECT * FROM #{table} WHERE 
                 "Statuses_id" <> $1 AND 
                 "Books_id" = $2 AND 
                 "Users_id" = $3 """, 
                 [util.status.CLOSED, requestInfo.Books_id, 
                  requestInfo.Users_id], (rows) => 
                    if rows.length == 0
                        success()
                    else
                        failure()
                )
        
checkNoDupRequest = checkNoDup('require')

checkNoDupSell    = checkNoDup('sell')

createObject  = (table) =>
    (objectInfo, callback) =>
        console.log("createObject(#{JSON.stringify objectInfo}) on #{table}")
        db.insert(table, _.omit(objectInfo, 'bookData'), (inserted) => 
                  callback _.extend(inserted, _.pick(objectInfo, 'bookData')))

createRequest = createObject('require')

createSell    = createObject('sell')

mkSendResultsFactory = (send, results = { success: [], failure: [] }) =>
    (success) =>
        esit = if success then 'success' else 'failure'
        (objInfo, reason = '') =>
            console.log(objInfo, esit, reason)
            resultData = { obj: objInfo, reason: reason }
            results[esit].push resultData
            send(results) # send callback handles 'type' of results
                          # Note send is triggered just when last result is
                          # collected

insertNegotiation = (request, sell, callback) =>

    console.log "insertNegotiation(#{JSON.stringify request}, 
    #{JSON.stringify sell})"
    setAssigned = (table, id) =>
        (cback) =>
            console.log "setAssigned on #{table}"
            db.query("""UPDATE #{table} SET "Statuses_id" = $1 
                 WHERE id = $2""", [util.status.ASSIGNED, id], 
                 callback, false, db.rollback)
    
    retrieveNegotiation = (cback) =>
        console.log 'retrieveNegotiation'
        # TODO : insert bookData + user data on single objects
        db.query("""SELECT n.id, 
                 r."Books_id" AS "r_Books_id", 
                 r."Users_id" AS "r_Users_id", 
                 r.id AS r_id,
                 r.creation_date AS creation_date
                 rs.name AS r_status
                 s."Books_id" AS "s_Books_id", 
                 s."Users_id" AS "s_Users_id", 
                 s.id AS s_id,
                 s.creation_date AS s_creation_date,
                 ss.name AS s_status
                 FROM negotiations AS n 
                 JOIN require AS r ON r.id = n."Request_id"
                 JOIN "Statuses" as rs ON r."Statuses_id" = rs.id
                 JOIN sell AS s ON s.id = n."Sell_id"
                 JOIN "Statuses" as ss ON s."Statuses_id" = ss.id
                 WHERE r."Users_id" = $1 AND
                 s."Users_id" = $2 AND
                 r."Books_id" = $3 AND
                 s."Books_id" = $3
                 """, cback)
        
    createNegotiation = () =>
    
        db.query("""INSERT INTO negotiation ("Require_id","Sell_id") 
                 VALUES ($1,$2)""", [request.id, sell.id], 
                 () =>
                    db.commit retrieveNegotiation callback)
    
    db.query('BEGIN',
                () => setAssigned('require', request.id)(
                    setAssigned('sell', sell.id)(createNegotiation)))
    
    
checkMatchingRequest = checkMatchingExists('require')

checkMatchingSell    = checkMatchingExists('sell')

insertRequest = (requestInfo, success, failure) =>
    checkNoDupRequest(requestInfo, => createRequest(requestInfo, 
                (request) => 
                    console.log 'checkNoDupRequest cb'
                    console.log 'returned request ' + JSON.stringify request
                    if (!request)
                      failure(requestInfo)
                    else
                      checkMatchingSell(request, 
                        (sell, request) => 
                          console.log 'checkMatchingSell cb'
                          if (sell?)
                              insertNegotiation(request, sell, 
                                        (negotiation) =>
                                        	sendMails negotiation
                                            success negotiation.request)
                          else
                              success request)
             ), 
             =>
                 failure(requestInfo, 
                         "E' già attiva una richiesta identica")
    )
    
insertOffer = (sellInfo, success, failure) =>
    checkNoDupSell(sellInfo, => createSell(sellInfo, 
                (sell) => 
                    console.log 'checkNoDupSell cb'
                    console.log 'returned sell ' + JSON.stringify sell
                    if (!sell)
                      failure(sellInfo)
                    else
                      checkMatchingRequest(sell, 
                        (request, sell) => 
                          console.log 'checkMatchingRequest cb'
                          if (request?)
                              insertNegotiation(request, sell, 
                                        (negotiation) =>
                                            success negotiation.sell)
                          else
                              success sell)
             ), 
             =>
                 failure(sellInfo, 
                         "E' già attiva un'offerta identica")
    )

    
insertObjects =  (insertSingle) =>
    (req, res) =>
        
        books         = req.body.books
        send          = _.after(books.length, (results) => 
                                res.render('op_result', results))
        mkSendResults = mkSendResultsFactory(send)
        success       = mkSendResults(SUCCESS)
        failure       = mkSendResults(FAILURE)
        
        asyncMap(books, ((bookId, callback) => 
                         db.retrieve('books', { id: bookId }, (book) =>
                                objInfo =
                                    bookData: book[0]
                                    Books_id: parseInt(bookId, 10)
                                    Users_id: parseInt(req.user.id, 10)
                                    Statuses_id: util.status.OPEN
                                callback(null, objInfo))), 
                        (err, objects) =>
                            if (err)
                                console.log("something went wrong with async: 
                                             #{JSON.stringify err}")
                                return
                            _.each(objects, (requestInfo) => 
                                insertSingle(requestInfo, success, failure)))


module.exports.insertRequests = insertObjects(insertRequest)

module.exports.insertOffers   = insertObjects(insertOffer)