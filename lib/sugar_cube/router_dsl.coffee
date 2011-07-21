express = require 'express'
Controller = require 'sugar_cube/controller'


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
    switch typeof @cb
      when 'function'
        Controller.toMiddleware @cb
      when 'string'
        [controller, action] = @cb.split '#'
        MiddlewareDefinition.resolveMiddleware controller, action
      when 'object'
        {controller, action} = @cb
        MiddlewareDefinition.resolveMiddleware controller, action
      else
        throw new Error("unknown route endpoint #{@cb}")
  
  # Validates the existence of controller and returns the resolved middleware
  # 
  # @controller {String} the controller name
  # @action {String} the controller action (or skip if rest)
  # @api public
  @resolveMiddleware: (controller, action) ->
    throw new Error("cannot resolve controller") unless controller?
    controller = @findController controller
    action = 'index' unless action?
    controller.toMiddleware action
    
  # Requires the given controller based on the controllersPath configuration
  #
  # @controller {String} the controller name
  # @api public
  @findController: (controller) ->
    require "#{@controllersPath}/#{controller}"


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
#     # index.coffee
#     h1 -> @title 
#
# Controller callback example:
#
#     # routes.coffee
#     @get '/', to 'tweets#index'
#     @get '/create', to controller: 'tweets', action: 'create'
#
#@cb {Function|String|Object} the router callback function or controller-defining string/object
#@api public
to = (cb) -> new MiddlewareDefinition(cb).toMiddleware() # TODO: namespace, module


# Monkey patch express-resource #route to autoload rest controller actions
#
#     class Users extends Controller
#       @action index: -> @render 'index'
#       ...
#
#     @resource 'users'
#
#@name {string} the controller name
#@api public
resource = express.HTTPServer.prototype.resource
express.HTTPServer.prototype.resource =
express.HTTPSServer.prototype.resource = (name) -> # TODO: collection, member
  controller = MiddlewareDefinition.findController name
  resource.call @, name, controller.toRestMiddlewares()


exports.MiddlewareDefinition = MiddlewareDefinition
exports.to = to

