{Controller} = require 'controller'
models = require '../models'
Tweet = models.Tweet

class Tweets extends Controller
  
  index: ->
    Tweet.find (@err, @tweets) => @render 'tweets/index'
    
  create: ->
    @tweet = new Tweet @param 'tweet'
    @tweet.save (@err) => @redirect 'back'
    
module.exports = Tweets
