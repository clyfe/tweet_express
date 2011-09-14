module.exports = ->

  # Can use function callbacks that run inside of a controller context
  @get '/', to: ->
    @title = "Hello route function!"
    @render 'index'

  # Can use controller actions callbacks
  @get '/tweets', to: 'tweets#index', as: 'tweets'
  @post '/tweets', to: {controller: 'tweets', action: 'create'}, as: 'create_tweet'
  
  @get '/admin/tweets', to: 'admin/tweets#index', as: 'admin_tweets'
  
  # Namespaces
  @namespace '/admin', ->
    # Can use REST routing via express-resource
    # Users controller also uses scaffold in this example
    @resource 'users' # admin_users_create
    
    @get '/test', to: ->
      @title = "Hello namespace!"
      @render 'index'

