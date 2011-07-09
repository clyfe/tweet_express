{Controller, to} = require 'controller'
models = require './models'
Tweet = models.Tweet

module.exports = ->

  @get '/', to ->
    Tweet.find (@err, @tweets) => @render 'index'

  @post '/tweets', to ->
    @tweet = new Tweet @param 'tweet'
    @tweet.save (@err) => @redirect 'back'

