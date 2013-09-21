_  = require 'underscore'
db = require __dirname + '/Db'


module.exports.compactFlash = (msgArray, cls = 'error') ->
	console.log JSON.stringify(msgArray)
	('<p class="{#cls}">' + msg + "</p>" for msg in msgArray).join('')

	
module.exports.getClasses = (callback) =>
	db.query("""SELECT id, year || ' ' || section AS class FROM classes
""", (rows) => callback({ classes: rows }))
        
module.exports.status =
    OPEN:     1
    ASSIGNED: 2
    CLOSED:   3
    
#to understand how it works see test in `test/util.js`
module.exports.normalizeTuples =  (tups, conf) =>

    contains =  (coll, item) =>
        _.some(coll,  (it) =>
            _.isEqual(it, item)
        )

    ordering = _.reduce(tups, ((memo, tup) =>
            if (not _.contains(memo, tup[conf.id]))
                memo.push tup[conf.id]
            memo),
        [])

    # if no key grouping specified, treat all as single properties
    _.defaults(conf, { keys: {} });
    result = []
    if (tups.length > 0)
        # keys to set on normalized tuple
        # that have to be taken from original tuple (no grouping)
        keys = _.difference(_.without(_.keys(tups[0]), conf.id), 
            _.flatten(_.map(_.values(conf.keys), _.values)))
        _.each(_.groupBy(tups, conf.id),  
               (entityTups, id) =>      
                    result.push( 
                        =>
                            # groups values belonging to same id
                            allArrays = _.reduce(entityTups, 
                                ((acc, tup) =>
                                    # groupedKeys = keys of referenced  
                                    # entity to be created
                                    # asKey = key that collects the array 
                                    # of new entities
                                    _.each(conf.keys,  (groupedKeys, asKey) =>
                                        # key grouped as objects
                                        if (_.isUndefined(acc[asKey]))
                                            acc[asKey] = []
                                        value = {}
                                        _.each(groupedKeys,  (val, key) =>
                                            value[key] = tup[val]
                                        )
                                        if (not contains(acc[asKey], value)) 
                                            acc[asKey].push(value)
                                    )
                                    acc
                                ),
                                () =>
                                    # generate accumulator for reduce:
                                    # set id and values that do not need 
                                    # grouping just int ids supported
                                    ret = _.pick.apply(_, 
                                                       [entityTups[0]].concat keys)
                                    if ret[conf.id] = /0|[1-9][0-9]*/.test id
                                    then parseInt(id, 10) else id
                                    ret
                            ) # close reduce 
                            rez = {}
                            _.each(allArrays, 
                                   (value, key) =>
                                        # reconvert arrays of arity 1 
                                        # to single value
                                        # still working on single tuple 
                                        # w.r.t. output
                                        if (_.isArray(value) and value.length == 1)
                                            # as we use left join we can find 
                                            # all null tuples
                                            if (_.some(_.values(value[0]), 
                                                       (v) => v != null))
                                                rez[key] = value[0]
                                            else 
                                                rez[key] = null
                                        else
                                            rez[key] = value
                            )
                            rez
                    ) # closes push
            ) # closes each
    _.sortBy(result, (item) =>
        ordering.indexOf(item[conf.id])
    )
