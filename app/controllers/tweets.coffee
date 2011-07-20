Controller = require 'sugar_cube/controller'
Tweet = require 'models/tweet'


class Tweets extends Controller
  
  # TODO: filters
  # @filter before: 'log_request'
  # @filter before: ->
  #   logger.info request
  
  @action index: ->
    Tweet.find (@err, @tweets) => @render 'tweets/index'
    
  @action create: ->
    @tweet = new Tweet @param 'tweet'
    @tweet.save (@err) => @redirect 'back'


module.exports = Tweets

