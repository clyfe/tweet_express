### About

Application kikstart for Express + Mongoose in CoffeeScript with a thin sintactic sugar layer and minimal structure.  
Makes writing small-ish Express apps in CoffeeScript a little better.


### Highlights

* Controller objects that you can use as MVC or plain Express routes callbacks
* niceties to make code less verbose, less typing, cleaner code
* nice MVC structure inspired by Rails
* flexible conventions
* base application skeleton


### Examples

#### Routing example

```coffeescript
# app/routes.coffee
{to} = require 'sugar_cube/router_dsl'


module.exports = ->

  # Can use function callbacks
  @get '/', to ->
    @title = "Hello from route function!"
    @render 'index'

  # Can use controller actions callbacks
  @get '/tweets', to 'tweets#index'
  @post '/tweets', to controller: 'tweets', action: 'create'
```


#### Controller example

```coffeescript
# app/controllers/tweets.coffee
Controller = require 'sugar_cube/controller'
Tweet = require 'models/tweet'


class Tweets extends Controller
  
  @action index: ->
    Tweet.find (@err, @tweets) => @render 'tweets/index'
    
  @action create: ->
    @tweet = new Tweet @param 'tweet'
    @tweet.save (@err) => @redirect 'back'


module.exports = Tweets
```


#### Views example

```html
<!-- views/index.eco -->
<h1><%= @title %></h1>
```

```html
<!-- views/tweets/index.eco -->

<h1>Express</h1>

<% for tweet in @tweets: %>
  <p><%= tweet.body %></p>
<% end %>

<form action="/tweet" method="post">
  <input type="text" name="tweet[body]"></input>
  <input type="submit">
</form>
```

Look at the code in the `lib/` folder to see the code making these posible, it's nicely documented.


### Code reload

1. Via [cluster reload](http://learnboost.github.com/cluster/docs/reload.html)
  * `coffee cluster.coffee` (see `cluster.coffee` file)

2. Via [node-supervisor](https://github.com/isaacs/node-supervisor)
  * install `sudo npm install supervisor -g`  
  * run with `supervisor app.coffee`


### Debug

See [node-inspector](https://github.com/dannycoates/node-inspector)


### File structure

```
app/
  controllers/ - controller files
  models/ - Mongoose models
  views/ - eco view files
  config.coffee - environment configuration, middleware, database connection
  helpers.coffee - view helpers here
  routes.coffee - routes definitions
lib/ - library code
app.coffee - server boot and configuration
cluster.coffee - cluster support
```

