Controller = require 'controller'


# An overly-complicated definition-to-middleware made for the sole purpose so that
# the end user can be able to customize it if he has to.
#
#@api public
class MiddlewareDefinition

  # Path prefix of controller directories
  # If controller are in "/app/controllers" and "/app" is in the require path,
  # then set to "controllers"
  #
  # @api public
  @controllersPath: 'controllers'
  
  # Create a MiddlewareDefinition from a function/string/object
  #
  # @cb {Function|String|Object} the router callback function or controller-defining string/object
  # @api public
  constructor: (@cb) ->
  
  # Returns a Connect middleware for this definition
  #
  # @api public
  toMiddleware: ->
    fn = switch typeof @cb
      when 'function'
        Controller.toMiddleware @cb
      when 'string'
        [controller, action] = @cb.split '#'
        @resolveMiddleware(controller, action)
      when 'object'
        {controller, action} = @cb
        @resolveMiddleware(controller, action)
      else
        throw new Error("unknown route endpoint #{@cb}")
    @wrapErrorsMiddleware(fn)
  
  # Validates the existence of controller/action and returns the resolved middleware
  # 
  # @controller {String} the controller name
  # @action {String} the controller action
  # @api private
  resolveMiddleware: (controller, action) ->
    throw new Error("cannot resolve controller") unless controller?
    throw new Error("cannot resolve action") unless action?
    controller = require("#{@constructor.controllersPath}/#{controller}")
    controller.toMiddleware action
  
  # Wraps a middleware in an error catching middlware that forwards any thrown errors to next()
  #
  # @api private
  wrapErrorsMiddleware: (fn) ->
    (req, res, next) ->
      try
        fn(req, res, next)
      catch err
        next(err)


# Returns a function that conforms to Express router api, that wraps the provided "cb" function or controller.
# If "cb" is a function, it is executed in a Context object instance, at req time.
# If it's a controller it is executed in the controller object.
#
# Route function callback example:
#
#     # routes.coffee
#     @get '/', to ->
#       @title = 'Express'
#       @render 'index'
#
#     # index.eco
#     <h1><%= @title %></h1>
#
# Controller callback example:
#
#     # routes.coffee
#     @get '/', to 'tweets#index'
#     @get '/create', to controller: 'tweets', action: 'create'
#
#@cb {Function|String|Object} the router callback function or controller-defining string/object
#@api public
to = (cb) -> (new MiddlewareDefinition(cb)).toMiddleware()


exports.MiddlewareDefinition = MiddlewareDefinition
exports.to = to

