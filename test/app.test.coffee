# Run $ expresso


assert = require 'assert'
{EventEmitter} = require('events')
mongoose = require 'mongoose'
app = require '../app'
Tweet = require 'models/tweet'
_ = require 'underscore'


doneTracker = new EventEmitter()


module.exports =


  'GET /': ->
    assert.response app, 
      url: '/',
    ,
      status: 200, 
      headers: {'Content-Type': 'text/html; charset=utf-8'}
    ,
      (res) -> 
        assert.includes res.body, '<p>Hello from route function!</p>'
        doneTracker.emit 'testDone'


  'GET /tweets': ->
    tweet = new Tweet body: 'A tweet body for testing GET /tweets'
    tweet.save (err) ->
      assert.response app, 
        url: '/tweets',
      ,
        status: 200,
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      ,
        (res) ->
          tweet.remove()
          assert.includes res.body, "</p>#{tweet.body}</p>"
          doneTracker.emit 'testDone'


  'POST /tweets': ->
    body = 'A tweet body for testing POST /tweet'
    assert.response app,
      method: 'POST', 
      url: '/tweets', 
      data: "tweet[body]=#{body}"
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
    ,
      status: 302, # redirects to referrer or base
    ,
      (res) -> 
        Tweet.find {}, (err, tweets) ->
          assert.ok _.any tweets, (t) -> t.body == body
          doneTracker.emit 'testDone'


totalTests = _.keys(module.exports).length
testsDone = 0
doneTracker.on 'testDone', -> 
  testsDone++
  mongoose.disconnect() if testsDone == 3

