Controller = require 'sugar_cube/controller'
Tweet = require 'models/tweet'


class Tweets extends Controller
  
  @action index: ->
    Tweet.find (@err, @tweets) => @render 'index'


module.exports = Tweets

