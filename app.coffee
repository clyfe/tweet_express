
###
Module dependencies.
###

express = require 'express'

app = module.exports = express.createServer()

# Configuration

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'eco'
  app.use(express.cookieParser());
  app.use(express.session({ secret: "0123456789" }));
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', ->
  app.use express.errorHandler(dumpExceptions: true, showStack: true)

app.configure 'production', ->
  app.use express.errorHandler()

# Routes
require('./routes').call app

app.listen 4000
console.log "Express server listening on port %d", app.address().port
