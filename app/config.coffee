express = require 'express'

module.exports = ->

  @configure ->
    @set 'views', __dirname + '/views'
    @set 'view engine', 'eco'
    @use express.cookieParser()
    @use express.session(secret: "0123456789")
    @use express.bodyParser()
    @use express.methodOverride()
    @use @router
    @use express.static(__dirname + '/../public')
    
  
  # Per environment configuration

  @configure 'development', ->
    @use express.errorHandler(dumpExceptions: true, showStack: true)
    @set 'mongoose url', 'mongodb://localhost/tweet_express_development'

  @configure 'test', ->
    @use express.errorHandler(dumpExceptions: true, showStack: true)
    @set 'mongoose url', 'mongodb://localhost/tweet_express_test'

  @configure 'production', ->
    @use express.errorHandler()
    @set 'mongoose url', 'mongodb://localhost/tweet_express_production'

