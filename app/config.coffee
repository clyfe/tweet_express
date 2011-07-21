express = require 'express'
coffeekup = require 'coffeekup'
i18n = require 'polyglot'


module.exports = ->

  @configure ->
    @set 'views', __dirname + '/views'
    @register '.coffee', coffeekup
    @set 'view engine', 'coffee'
    @use express.cookieParser()
    @use express.session(secret: "0123456789")
    @use express.bodyParser()
    @use express.methodOverride()
    
    @use i18n(default: 'en', path: '/app/lang', views: '/app/views', debug: true)
    @helpers(t: i18n.translate, n: i18n.plural, languages: i18n.languages)
		
    @use @router
    @use express.static(__dirname + '/../public')
    
  
  # Per environment configuration

  @configure 'development', ->
    # i18n.updateStrings() # buggy, and also we prefer t to __
    @use express.errorHandler(dumpExceptions: true, showStack: true)
    @set 'mongoose url', 'mongodb://localhost/tweet_express_development'

  @configure 'test', ->
    i18n.options.debug = false # less verbose
    @use express.errorHandler(dumpExceptions: true, showStack: true)
    @set 'mongoose url', 'mongodb://localhost/tweet_express_test'

  @configure 'production', ->
    i18n.options.debug = false
    @use express.errorHandler()
    @set 'mongoose url', 'mongodb://localhost/tweet_express_production'

