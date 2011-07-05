### About

Application kikstart for Express + Mongoose in CoffeeScript with a thin sintactic sugar layer and minimal structure.  
Makes writing small-ish Express apps in CoffeeScript a little better.

### Highlights

Writes like so

# routes.coffee
```coffeescript
  @get '/', to ->
    Tweet.find (err, @tweets) =>
      @render 'index'
```

# views/index.eco
```eco
  <h1><%= @title %></h1>
```

Look at control.coffee file.

### File structure

app.coffee - server boot and configuration
control.coffee - sugar layer lib code, you usually don't edit this file
helpers.coffee - put your view helpers here
models.coffee - Mongoose model code
routes.coffee - routes definitions
views/ - eco view files

