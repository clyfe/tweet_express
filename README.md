### About

Application kikstart for Express + Mongoose in CoffeeScript with a thin sintactic sugar layer and minimal structure.  
Makes writing small-ish Express apps in CoffeeScript a little better.

### Highlights

Writes like so

```coffeescript
# routes.coffee

@get '/', to ->
  Tweet.find (@err, @tweets) => @render 'index' # auto-handles err, renders

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
  <input type="text" name="tweet[body]"></input><br>
  <input type="submit">
</form>
```

Look at control.coffee file.

### File structure

```
app.coffee - server boot and configuration
control.coffee - sugar layer lib code, you usually don't edit this file
helpers.coffee - put your view helpers here
models.coffee - Mongoose model code
routes.coffee - routes definitions
views/ - eco view files
```
