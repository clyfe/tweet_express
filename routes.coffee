{Controller, to} = require './control'
models = require './models'
Tweet = models.Tweet

module.exports = ->

  @get '/', to ->
    Tweet.find (@err, @tweets) => @render 'index'

  @post '/tweet', to ->
    @tweet = new Tweet @param 'tweet'
    @tweet.save (@err) => @redirect 'back'

