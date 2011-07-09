{Controller, to} = require 'controller'
models = require './models'
Tweet = models.Tweet

module.exports = ->

  # Can use function callbacks
  @get '/', to ->
    @title = "Hello from route function!"
    @render 'index'

  # Can controller actions callbacks
  @get '/tweets', to 'tweets#index'
  @post '/tweets', to 'tweets#create'

