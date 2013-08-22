db = require __dirname + '/Db'


module.exports.getBooksByClass = (clazz, callback) =>
	[year, section] = clazz.split(' ')
	db.query("""SELECT b.isbn,b.id,b.title,b.author,b.price
				FROM books AS b 
				JOIN classes_books AS cb ON b.id = cb."Books_id"
				JOIN classes AS c 
				ON c.id = cb."Classes_id" 
				WHERE c.year = $1 AND 
				      c.section = $2""", [year, section], 
				      (rows) => callback({ books: rows }))
