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
  
  # A scaffold controller
  @resource 'tags'
  
  @namespace '/admin', ->
    @get '/hi', to ->
      @title = "Hello from namespace!"
      @render 'index'
