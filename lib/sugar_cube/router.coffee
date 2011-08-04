express = require 'express'
toArray = require('express/lib/utils').toArray
router = require 'express/lib/router'
methods = router.methods.concat('del', 'all')
Controller = require 'sugar_cube/controller'


# An overly-complicated definition-to-middleware made for the sole purpose so that
# the end user can be able to customize it if he has to.
#
#@api public
class MiddlewareDefinition
  
  # Create a MiddlewareDefinition from a function/string/object
  #
  # @param {Function|String|Object} cb - the router callback function or controller-defining string/object
  # @api public
  constructor: (@app, @cb) ->
  
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
        @resolveMiddleware controller, action
      when 'object'
        {controller, action} = @cb
        @resolveMiddleware controller, action
      else
        throw new Error("unknown route endpoint #{@cb}")
  
  # Validates the existence of controller and returns the resolved middleware
  # 
  # @param {String} controller - the controller name
  # @param {String} action - the controller action (or skip if rest)
  # @return {Function} a Connect middleware (that resolves to the given controller and action)
  # @api public
  resolveMiddleware: (controller, action) ->
    throw new Error("cannot resolve controller") unless controller?
    controller = MiddlewareDefinition.findController @app, controller
    action = 'index' unless action?
    controller.toMiddleware action
    
  # Requires the given controller based on the controllersPath configuration
  #
  # @param {Object} app - the configured Express server
  # @param {String} controller - the controller name
  # @return {Object} the controller class
  # @api public
  @findController: (app, controller) ->
    controllersPath = app.set 'controllers path'
    require "#{controllersPath}/#{controller}"


# Monkey patch server routing functions to autoload controller actions
# Old versions still work
#
#     class Users extends Controller
#       @action index: -> @render 'index'
#       ...
#
#     @get '/users', to: 'users#index'
#
#@param {String} name - the controller name
#@api public
app = express.HTTPServer::
methods.forEach (method) ->
  old = app[method]
  app[method] = (path) ->
    return old.apply(@, arguments) if 1 == arguments.length # just like old api
    cb = arguments[1]
    switch typeof cb
      when 'function' # just like old api
        old.apply(@, arguments)
      when 'object' # this is where we come in
        args = [method].concat toArray(arguments)
        args[2] = new MiddlewareDefinition(@, cb['to']).toMiddleware()
        @use(this.router) if !@.__usedRouter
        @routes._route.apply @routes, args


# Monkey patch express-resource #route to autoload rest controller actions
#
#     class Users extends Controller
#       @action index: -> @render 'index'
#       ...
#
#     @resource 'users'
#
#@param {String|Object} name - the controller name
#@api public
resource = express.HTTPServer::resource
express.HTTPServer::resource =
express.HTTPSServer::resource = (name) -> # TODO: collection, member
  if 1 == arguments.length
    controller = MiddlewareDefinition.findController @, name
    resource.call @, name, controller.toRestMiddlewares()
  else
    resource.apply @, arguments


exports.MiddlewareDefinition = MiddlewareDefinition

