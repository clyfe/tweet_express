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
  # @param {Function|String|Object} cb - the router callback function or controller-defining string/object
  # @api public
  constructor: (@cb) ->
  
  # Returns a Connect middleware for this definition
  #
  # @return {Function} a Connect middleware (that resolves to the specified Controller)
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
  # @param {String} controller - the controller name
  # @param {String} action - the controller action (or skip if rest)
  # @return {Function} a Connect middleware (that resolves to the given controller and action)
  # @api public
  @resolveMiddleware: (controller, action) ->
    throw new Error("cannot resolve controller") unless controller?
    controller = @findController controller
    action = 'index' unless action?
    controller.toMiddleware action
    
  # Requires the given controller based on the controllersPath configuration
  #
  # @param {String} controller - the controller name
  # @return {Object} the controller class
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
# @param {Function|String|Object} cb - the router callback function or controller-defining string/object
# @return {Function} a Connect middleware (resolved to the given specification)
# @api public
to = (cb) -> new MiddlewareDefinition(cb).toMiddleware() # TODO: namespace, module


# Monkey patch express-resource #route to autoload rest controller actions
#
#     class Users extends Controller
#       @action index: -> @render 'index'
#       ...
#
#     @resourceTo 'users'
#
#@param {String} name - the controller name
#@api public
express.HTTPServer.prototype.resourceTo =
express.HTTPSServer.prototype.resourceTo = (name) -> # TODO: collection, member
  controller = MiddlewareDefinition.findController name
  @resource name, controller.toRestMiddlewares()


exports.MiddlewareDefinition = MiddlewareDefinition
exports.to = to

