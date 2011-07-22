express = require 'express'
coffeekup = require 'coffeekup'
i18n = require 'sugar_cube/i18n'


module.exports = ->

  @configure ->
    @set 'views', __dirname + '/views'
    @register '.coffee', coffeekup
    @set 'view engine', 'coffee'
    @use express.cookieParser()
    @use express.session(secret: "0123456789")
    @use express.bodyParser()
    @use express.methodOverride()
    
    @use i18n(default: 'en', path: '/app/locales', views: '/app/views')
    @helpers(__: i18n.translate, n: i18n.plural, languages: i18n.languages)
		
    @use @router
    @use express.static(__dirname + '/../public')
    
  
  # Per environment configuration

  @configure 'development', ->
    # i18n.updateStrings() # buggy, and also we prefer t to __
    @use express.errorHandler(dumpExceptions: true, showStack: true)
    @set 'mongoose url', 'mongodb://localhost/tweet_express_development'

  @configure 'test', ->
    @use express.errorHandler(dumpExceptions: true, showStack: true)
    @set 'mongoose url', 'mongodb://localhost/tweet_express_test'

  @configure 'production', ->
    @use express.errorHandler()
    @set 'mongoose url', 'mongodb://localhost/tweet_express_production'

