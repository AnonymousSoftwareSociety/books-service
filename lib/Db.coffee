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
        if _.isArray params then cli.query(qs, params, rowsCallback) 
        else cli.query(qs, rowsCallback)

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
        # TODO merge with retrieve
        module.exports.query("INSERT INTO #{table} #{ksString} VALUES
                             #{dummyString}", kVal.vls, callback)


    module.exports.retrieve = (table, object, callback) =>
    
        kVal = _.reduce(object, (vls, value, key) => 
                              vls.cnt += 1
                              vls.vls.push value
                              vls.Str.push """#{key} = #{
                                  if _.isString key then '"$' + vls.cnt +
                                            '"' else '$' + vls.cnt} """,
                              { cnt: 0, vls: [], Str: [] })
                              
        module.exports.query("SELECT * FROM #{table} WHERE 
                             #{kVal.Str.join('AND ')}", kVal.vls, callback)

    return module.exports