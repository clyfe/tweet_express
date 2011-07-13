{to} = require 'router_dsl'


module.exports = ->

  # Can use function callbacks
  @get '/', to ->
    @title = "Hello from route function!"
    @render 'index'

  # Can use controller actions callbacks
  @get '/tweets', to 'tweets#index'
  @post '/tweets', to controller: 'tweets', action: 'create'

