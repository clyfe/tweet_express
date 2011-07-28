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

  # Can use REST routing via express-resource
  @resource 'users'
  
  # Namespaces
  @namespace '/admin', ->
    @get '/hi', to ->
      @title = "Hello from namespace!"
      @render 'index'
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

```coffeescript
# views/index.coffee
h1 -> @title
```

```coffeescript
# views/tweets/index.coffee
h1 -> 'Express'

for tweet in @tweets
  p -> tweet.body

form action: "/tweet", method: "post" ->
  input type: "text", name: "tweet[body]"
  input type: "submit"
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
  lang/ - I18n JSON files (soon to be CSON)
  models/ - Mongoose models
  views/ - CoffeeKup view files
  config.coffee - environment configuration, middleware, database connection
  helpers.coffee - view helpers here
  routes.coffee - routes definitions
lib/ - library code
app.coffee - server boot and configuration
cluster.coffee - cluster support
```


### Coming soon

* Scaffolding
* View helpers
* routing DSL improvements
* I18n api improvements
* logging with winston https://github.com/indexzero/winston

