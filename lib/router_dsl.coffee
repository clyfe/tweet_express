Controller = require 'controller'


###
Returns a function that conforms to Express router api, that wraps the provided "cb" function or controller.
If "cb" is a function, it is executed in a Context object instance, at req time.
If it's a controller it is executed in the controller object.

Route function callback example:

    # routes.coffee
    @get '/', to ->
      @title = 'Express'
      @render 'index'

    # index.eco
    <h1><%= @title %></h1>

Controller callback example:

    # routes.coffee
    @get '/', to 'tweets#index'
    @get '/create', to controller: 'tweets', action: 'create'

@cb {Function|String|Object} the router callback function or controller-defining string/object
@api public
###
to = (cb) ->
  
  fn = switch typeof cb
    when 'function'
      Controller.to_middleware cb
    when 'string'
      [controller, action] = cb.split '#'
      require("controllers/#{controller}").to_middleware action
    when 'object'
      {controller, action} = cb
      require("controllers/#{controller}").to_middleware action
    else
      throw new Error("unknown route endpoint #{cb}")
  
  (req, res, next) ->
    try
      fn(req, res, next)
    catch err
      next(err)


module.exports = to

