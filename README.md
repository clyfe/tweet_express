### About

Application kikstart for Express + Mongoose in CoffeeScript with a thin sintactic sugar layer and minimal structure.  
Makes writing small-ish Express apps in CoffeeScript a little better.


### Highlights

* context object to execute route functions in it
* auto-forwards errors to next when it's the case
* less typing ie. `@render 'tpl'` instead `res.render 'tpl' locals: {...}`

Writes like so

```coffeescript
# routes.coffee

@get '/', to ->
  # auto-handles err via __defineSetter__ 'err', renders
  # @tweets are available in views, no more `locals: {}` noise
  Tweet.find (@err, @tweets) => @render 'index'

@post '/tweet', to ->
  @tweet = new Tweet @param 'tweet'
  @tweet.save (@err) => @redirect 'back' # auto-handles err, renders
```


```html
<!-- views/index.eco -->

<h1>Express</h1>

<% for tweet in @tweets: %>
  <p><%= tweet.body %></p>
<% end %>

<form action="/tweet" method="post">
  <input type="text" name="tweet[body]"></input>
  <input type="submit">
</form>
```

Look at `control.coffee`, file that's where all the magic happens.


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
app.coffee - server boot and configuration
control.coffee - sugar layer lib code, you usually don't edit this file
helpers.coffee - put your view helpers here
models.coffee - Mongoose model code
routes.coffee - routes definitions
views/ - eco view files
```

