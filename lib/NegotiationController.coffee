db   = require __dirname + '/Db'
_    = require 'underscore'
util = require __dirname + '/util'

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
                    if rows.length > 0 
                        callback(rows[0], object)
                    else 
                        callback(null, object))


checkNoDup = (table) =>
    (requestInfo, success, failure) =>
        console.log "checkNoDup on #{table}"
        db.retrieve(table, requestInfo, (rows) => 
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
        db.insert(table, objectInfo, callback)

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
            
createNegotiation = (request, sell, callback) =>
    # TODO (pay attention with param order)
    callback { request: request, sell: sell }
    
    
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
                      checkMatchingSell(requestInfo, 
                        (sell, request) => 
                          console.log 'checkMatchingSell cb'
                          if (sell?)
                              createNegotiation(request, sell, 
                                        (negotiation) =>
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
                      checkMatchingRequest(sellInfo, 
                        (request, sell) => 
                          console.log 'checkMatchingRequest cb'
                          if (sell?)
                              createNegotiation(request, sell, 
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
        requests      = _.map(books, 
                            (bookId) => 
                                book =
                                    Books_id: parseInt(bookId, 10)
                                    Users_id: parseInt(req.user.id, 10)
                                    Statuses_id: util.status.OPEN
                                book)
        send          = _.after(books.length, (results) => res.json results)
        mkSendResults = mkSendResultsFactory(send)
        success       = mkSendResults(SUCCESS)
        failure       = mkSendResults(FAILURE)
        
        _.each(requests, (requestInfo) => insertSingle(
            requestInfo, success, failure))

module.exports.insertRequests = insertObjects(insertRequest)

module.exports.insertOffers   = insertObjects(insertOffer)