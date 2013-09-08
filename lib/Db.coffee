_db = require 'pg'
_   = require 'underscore'

module.exports = (options) -> 
    cli = new _db.Client(options)
    cli.connect()

    
    
    module.exports.query = (qs, params, callback, verbose) ->
        if verbose is undefined
            verbose = false
        callback = params if _.isFunction params
        rowsCallback = (err, result) => 
            if err
                errMsg = "Postgres error:: #{err}"
                console.log errMsg
            else
                callback(if not verbose then result.rows else result)
        if _.isArray params then cli.query(qs, params, rowsCallback) else cli.query(qs, rowsCallback)

    module.exports.VERBOSE = true

    _mkVString = (arr) => '(' +  arr.join(',') + ')'

    module.exports.insert = (table, object, callback) =>
        
        kVal = _.reduce(object, (kVal, value, key) => 
            kVal.ks.push key
            kVal.vls.push value
            kVal.dummy.push '$' + kval.dummy.length + 1, 
        { ks: [], dummy: [], vls: [] })
        
        ksString    = _mkVString kVal.ks 
        dummyString = _mkVString kVal.dummy
        
        module.exports.query("INSERT INTO #{table} #{ksString} VALUES
                             #{dummyString}", kVal.vls, callback)

    #TODO
    module.exports.retrieve = undefined

    return module.exports