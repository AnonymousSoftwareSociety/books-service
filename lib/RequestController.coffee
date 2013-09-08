db = require __dirname + '/Db'
_  = require 'underscore'

SUCCESS = true
FAILURE = false

checkMatchingExists = (table) =>
    (object, callback) => 
        db.query("SELECT id FROM #{table} AS sl
                    WHERE sl.Books_id = $1 AND 
                          sl.Statuses_id = $2
                    ORDER BY sl.creation_date ASC
                    LIMIT 0 1", [object.bookId, util.status.OPEN], 
                (rows) => 
                    if rows.length > 0 
                        callback(rows[0], object)
                    else 
                        callback(null, object))


checkNoDup = (table) =>
    (requestInfo, success, failure) =>
        db.query("""
                SELECT * FROM #{table} WHERE 
                "Statuses_id" = (SELECT id FROM statuses 
                WHERE name = 'OPEN')
                AND "Users_id" = $1 AND "Books_id" = $2
                """, 
                [requestInfo.userId, requestInfo.bookId], 
                (rows) => 
                    if rows.length == 0
                        success()
                    else
                        failure()
                )
        
checkNoDupRequest = checkNoDup('require')

checkNoDupSell = checkNoDup('sell')

createObject  = (table) => #TODO
    (objectInfo, callback) =>
        db.insert(table, objectInfo, callback)

createRequest = (requestInfo, callback) =>
    console.log 'createRequest'
    db.query('''
             INSERT INTO require ("Statuses_id","Users_id","Books_id") 
             VALUES ((SELECT id FROM statuses WHERE name = 'OPEN'),$1,$2)
             ''', [requestInfo.userId, requestInfo.bookId], 
             ((result) =>
                db.query('''
                         SELECT * FROM require WHERE 
                         "Statuses_id" = (SELECT id FROM statuses WHERE name = 'OPEN')
                         AND "Users_id" = $1 AND "Books_id" = $2
                         ''', 
                        [requestInfo.userId, requestInfo.bookId], 
                        (rows) => 
                            callback rows[0]
                 )
             )
    )

mkSendResultsFactory = (send, results = { success: [], failure: [] }) =>
    (success) =>
        esit = if success then 'success' else 'failure'
        (objInfo, reason = '') =>
            resultData = { obj: objInfo, reason: reason }
            results[esit].push resultData
            send(results) # send callback handles 'type' of results
            
createNegotiation = (request, sell, callback) =>
    # TODO (pay attention with param order)
    callback { request: request, sell: sell }
    
checkMatchingSell =  (request, callback) => checkMatchingExists('sell')

module.exports.insertRequest = (requestInfo, success, failure) =>
    checkNoDupRequest(requestInfo, => createRequest(requestInfo, 
                (request) => 
                    if (!request)
                      failure(requestInfo)
                    else
                      checkMatchingSell(request, 
                        (sell, request) => 
                          if (sell?)
                              createNegotiation(request, sell, 
                                        (negotiation) =>
                                            success negotiation.request)
                          else
                              success request)
             ), 
             =>
                 failure(requestInfo, 
                         "E' già stata aperta una richiesta identica")
    )
    
    
module.exports.insertRequests = (req, res) =>
    
    books         = req.body.books.split(',')
    reqNum        = books.length - 1
    requests      = _.map(books[...reqNum], (bookId) => 
                           { bookId: bookId, userId: req.user.id })
    send          = _.after(reqNum, (results) => res.json results)
    mkSendResults = mkSendResultsFactory(send)
    success       = mkSendResults(SUCCESS)
    failure       = mkSendResults(FAILURE)
    
    _.each(requests, (requestInfo) => module.exports.insertRequest(
        requestInfo, success, failure))
    
module.exports.insertSells = (req, res) =>