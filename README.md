### About

Application kikstart for Express + Mongoose in CoffeeScript with a thin sintactic sugar layer and minimal structure.  
Makes writing small-ish Express apps in CoffeeScript a little better.


### Highlights

* context object to execute route functions in it
* auto-forwards errors to next when it's the case
* less typing ie. `@render 'tpl'` instead `res.render 'tpl' locals: {...}`
* nice MVC structure inspired by Rails

Writes like so

```coffeescript
# routes.coffee

# function callbacks
@get '/', to ->
  # auto-handles err via __defineSetter__ 'err', renders
  # @tweets are available in views, no more `locals: {}` noise
  Tweet.find (@err, @tweets) => @render 'index'

# controller callbacks
@get '/', to 'tweets#index'
@get '/create', to controller: 'tweets', action: 'create'

# index.eco
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

Look at the code in the `lib/` folder, it's nicely documented.


### Code reload

1. Via [cluster reload](http://learnboost.github.com/cluster/docs/reload.html)
  * `coffee cluster.coffee` (see `cluster.coffee` file)

2. Via [node-supervisor](https://github.com/isaacs/node-supervisor)
  * install `sudo npm install supervisor -g`  
  * run with `supervisor app/app.coffee`


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
lib/
  controller.coffee - controller context
  router_dsl.coffee - routing helper
app.coffee - server boot and configuration
cluster.coffee - cluster support
```

