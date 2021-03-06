express = require 'express'
coffeekup = require 'coffeekup'
browserify = require 'browserify'
I18n = require 'sugar_cube/i18n'


module.exports = ->

  @configure ->
    @set 'views', __dirname + '/views'
    @register '.coffee', coffeekup
    @set 'controllers path', 'controllers'
    @set 'view engine', 'coffee'
    @set 'hints', false # mostly annoying
    @use express.cookieParser()
    @use express.session(secret: "0123456789")
    @use express.bodyParser()
    @use express.methodOverride()
    @use I18n.middleware
    @helpers I18n.helpers
		
    @use browserify
      mount: '/browserify.js'
      require: ['underscore', 'jquery-browserify']
      entry: "#{__dirname}/client/entry.coffee"
    
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

