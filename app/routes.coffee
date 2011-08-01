{to} = require 'sugar_cube/router_dsl'


module.exports = ->

  # Can use function callbacks
  @get '/', to ->
    @title = "Hello from route function!"
    @render 'index'

  # Can use controller actions callbacks
  @get '/tweets', to 'tweets#index'
  @post '/tweets', to controller: 'tweets', action: 'create'
  
  # Namespaces
  @namespace '/admin', ->
    # Can use REST routing via express-resource
    # Users controller also uses scaffold in this example
    @resourceTo 'users'
