db = require __dirname + '/Db'
_  = require 'underscore'

SUCCESS = true
FAILURE = false

# TODO generalize
checkMatchingExists = (table) =>
    (request, callback) => 
        db.query("SELECT id FROM #{table} AS sl
                    JOIN statuses AS s ON sl.Statuses_id = s.id
                    WHERE sl.Books_id = $1 AND 
                            s.name = 'OPEN' 
                    ORDER BY sl.creation_date ASC
                    LIMIT 0 1", [request.bookId], 
                (rows) => callback if rows.length > 0 then rows[0] else null)


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

createRequest = (requestInfo, callback) =>
    console.log 'createRequest'
    console.log JSON.stringify(requestInfo)
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
    # TODO
    callback { request: request, sell: sell }
    
checkMatchingSell =  => null
# TODO
# checkMatchingExists('sell')

module.exports.insertRequest = (requestInfo, success, failure) =>
    checkNoDupRequest(requestInfo, => createRequest(requestInfo, 
                (request) => 
                    if (!request)
                      failure(requestInfo)
                    else
                      checkMatchingSell(request, 
                      (sell) => 
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
    
    requests      = _.map(req.body.books, (bookId) => 
                           { bookId: bookId, userId: req.user.id })
    console.log(JSON.stringify(requests))
    send          = _.after(requests.length, (results) => res.json results)
    mkSendResults = mkSendResultsFactory(send)
    success       = mkSendResults(SUCCESS)
    failure       = mkSendResults(FAILURE)
    
    _.each(requests, (requestInfo) => module.exports.insertRequest(
        requestInfo, success, failure))
    
module.exports.insertSells = (req, res) =>