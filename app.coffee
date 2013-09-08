
###
 Module dependencies.
###

process.env.DATABASE_URL ?= 'postgres://darkjaglee:misonocapito@localhost:5432/books'

db            = require(__dirname + '/lib/Db')(process.env.DATABASE_URL)
express       = require 'express'
localStrategy = require('passport-local').Strategy
auth          = require __dirname + '/lib/Authentication'
userCtl       = require __dirname + '/lib/UserController'
bsUtil        = require __dirname + '/lib/util'
flash         = require 'connect-flash'
passport      = require 'passport'
routes        = require __dirname + '/lib/routes'
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
if 'dev' == process.env.NODE_ENV
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

loginConf =
    successRedirect: auth.successRedirect 
    failureRedirect: '/login'
    failureFlash: true
    
registerConf =
    message: bsUtil.compactFlash(req.flash('error'))


# Routes

app.get('/', routes.index)

# Login stuff

app.post('/login', passport.authenticate('local', loginConf))

app.get('/login', auth.login)

app.get('/logout', auth.logout)

# Registration stuff

app.get('/register', (req, res) -> res.render('register_dialog', registerConf))
app.post('/register', userCtl.register)

# From here on verify Logged in
app.all('*', auth.ensureAuthenticated)

# Wizard for requesting/offering books
# schema is :action/:step

app.get(new RegExp('^/(offer|request)/(1)?$'), routes.actionWizardSwitch)
app.post(new RegExp('^/(offer|request)/([2-9])$'), routes.actionWizardStep)

# Sink
app.all('*', (req, res) -> res.send(404))

http.createServer(app).listen(app.get('port'), 
() -> console.log ('Express server listening on port ' + app.get('port')))

