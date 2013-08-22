
###
 Module dependencies.
###

db            = require(__dirname + '/lib/Db')('postgres://darkjaglee:misonocapito@localhost:5432/books')
express       = require 'express'
localStrategy = require('passport-local').Strategy
auth          = require __dirname + '/lib/Authentication'
userCtl       = require __dirname + '/lib/UserController'
flash         = require 'connect-flash'
passport      = require 'passport'
routes        = require './routes'
mustache      = require 'mustache-express'
http          = require 'http'  
path          = require 'path'  
inspect       = require('util').inspect

app = express()

# all environments
app.set('port', process.env.PORT || 3000)
app.engine('mustache', mustache())
app.set('views', __dirname + '/views')  
app.set('view engine', 'mustache')  
app.use express.favicon()    
app.use express.logger 'dev'   
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.methodOverride()
app.use express.session({ secret: 'keyboard cat' })
app.use flash()
app.use passport.initialize()
app.use passport.session()   
app.use app.router
app.use express.static path.join(__dirname, 'public')

# development only
if  'development' == app.get 'env'
  app.use express.errorHandler
  
  
passport.serializeUser((user, done) ->
  done(null, user.id)
)

passport.deserializeUser((id, done) =>
  userCtl.getById(id, (user) -> 
  	err = new Error("Error in deserializing user")
  	if not user then done(err, false) else done(null, user)
  )
)
  
passport.use(new localStrategy((username, password, done) =>
    userCtl.getByUsername(username, (user) =>
      if not user
        return done(null, false, { message: 'Incorrect username.' })
      if not auth.check(user, password)
        return done(null, false, { message: 'Incorrect password.' })
      console.log 'authentication succeeded'
      return done(null, user)
    )
))


# Routes

app.get('/', routes.index)

app.post('/login', passport.authenticate('local', { successRedirect: '/', failureRedirect: '/login', failureFlash: true }),
	(req, res) => 
		res.redirect(auth.successRedirect)
)

app.get('/login', auth.login)

app.get('/logout', auth.logout)

app.get('/register', (req, res) -> res.render('register_dialog'))

http.createServer(app).listen(app.get('port'), 
() -> console.log ('Express server listening on port ' + app.get('port')))

