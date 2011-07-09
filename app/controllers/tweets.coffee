Controller = require 'controller'
Tweet = require 'models/tweet'

class Tweets extends Controller
  
  @action index: ->
    Tweet.find (@err, @tweets) => @render 'tweets/index'
    
  @action create: ->
    @tweet = new Tweet @param 'tweet'
    @tweet.save (@err) => @redirect 'back'


module.exports = Tweets

