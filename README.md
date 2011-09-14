### About

(Will evolve into an express-* umbrella framework)

Application kikstart for Express + Mongoose in CoffeeScript with a thin sintactic sugar layer and minimal structure.  
Makes writing small-ish Express apps in CoffeeScript a little better.


### Highlights

* Controller objects that you can use as MVC or plain Express routes callbacks
* niceties to make code less verbose, less typing, cleaner code
* nice MVC structure inspired by Rails
* flexible conventions
* base application skeleton
* CoffeeScript all the way down (CSON for language translations, CoffeeKup for views)


### Examples

#### Routing example

```coffeescript
# app/routes.coffee
module.exports = ->

  # Can use function callbacks that run inside of a controller context
  @get '/', to: ->
    @title = "Hello route function!"
    @render 'index'

  # Can use controller actions callbacks
  @get '/tweets', to: 'tweets#index'
  @post '/tweets', to: {controller: 'tweets', action: 'create'}
  
  # Namespaces
  @namespace '/admin', ->
    # Can use REST routing via express-resource
    @resource 'users'
    
    @get '/test', to: ->
      @title = "Hello namespace!"
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

form action: "/tweet", method: "post", ->
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

```shell
coffee --nodejs --debug app.coffee
```


### File structure

```
app/
  client/ - client specific modules (via browserify)
    entry.coffee - client main (see browserify)
    ...
  controllers/ - controller files
    users.coffee
    sessions.coffee
    ...
  locales/ - I18n CSON files (or JSON)
    en.cson
    es.cson
    ...
  models/ - Mongoose models
    user.coffee
    post.coffee
    ...
  views/ - CoffeeKup view files
    layouts/ - layout files
      application.coffee - default layout
    users/
      index.coffee
      new.coffee
      ...
  config.coffee - environment configuration, middleware, database connection
  helpers.coffee - view helpers here
  routes.coffee - routes definitions
lib/ - library code
app.coffee - server boot and configuration
cluster.coffee - cluster support
```


### Coming soon

* Scaffolding
* logging with winston https://github.com/indexzero/winston

