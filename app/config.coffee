express = require 'express'
mongoose = require 'mongoose'


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
    mongoose.connect 'mongodb://localhost/tweet_express'

  @configure 'development', ->
    @use express.errorHandler(dumpExceptions: true, showStack: true)

  @configure 'production', ->
    @use express.errorHandler()

