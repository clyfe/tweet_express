{Context, to} = require './control'
models = require './models'
Tweet = models.Tweet

module.exports = ->
  
  @get '/', to ->
    Tweet.find (err, @tweets) =>
      @render 'index'

  @get '/tweet', to ->
    @tweet = new Tweet()
    @tweet.body = @param 'body'
    @tweet.save (err) =>
      @redirect 'back'
