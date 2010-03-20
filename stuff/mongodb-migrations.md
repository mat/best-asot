MongoDB Migration Patterns
======

Adding a new field
-----
    idempotent? yes

	// Javascript
	db.collection.update({ newKey : { $exists : false } }, {$set : {newKey : null}}, false, true)

	# Ruby
	db = Mongo::Connection.new.db('mymongodb')
	db['collection'].update({'newKey' => { '$exists' => false }},{'$set' => {'newKey' => nil}}, :multi => true)

