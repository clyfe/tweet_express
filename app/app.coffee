express = require 'express'

module.exports = app = express.createServer()

# Configuration
app.configure ->
  @set 'views', __dirname + '/views'
  @set 'view engine', 'eco'
  @use express.cookieParser()
  @use express.session(secret: "0123456789")
  @use express.bodyParser()
  @use express.methodOverride()
  @use app.router
  @use express.static(__dirname + '/../public')

app.configure 'development', ->
  @use express.errorHandler(dumpExceptions: true, showStack: true)

app.configure 'production', ->
  @use express.errorHandler()

# Routes
require('./routes').call app

# Helpers
app.helpers require('./helpers')

if require.main == module
  app.listen 4000
  console.log "Express server listening on port %d", app.address().port

