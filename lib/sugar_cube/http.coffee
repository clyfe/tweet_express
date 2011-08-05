express = require 'express'
{toArray} = require 'express/lib/utils'
router = require 'express/lib/router'
methods = router.methods.concat('del', 'all')
Controller = require './controller'
HTTPServer = require './http'


class HTTPServer extends express.HTTPServer
  
  
  # Monkey patch init to create paths property on router
  init: (middleware) ->
    super middleware
    @router.paths = {}
  
  
  # Returns a Connect middleware for this definition
  #
  # @param {Function|String|Object} to - the middleware definition
  # @return {Function} a Connect middleware (that resolves to the specified Controller)
  # @api public
  buildMiddleware: (to) ->
    switch typeof to
      when 'function'
        Controller.toMiddleware to
      when 'string'
        [controller, action] = to.split '#'
        @resolveMiddleware controller, action
      when 'object'
        {controller, action} = to
        @resolveMiddleware controller, action
      else
        throw new Error("unknown route endpoint #{to}")


  # Validates the existence of controller and returns the resolved middleware
  # 
  # @param {String} controller - the controller name
  # @param {String} action - the controller action (or skip if rest)
  # @return {Function} a Connect middleware (that resolves to the given controller and action)
  # @api public
  resolveMiddleware: (controller, action) ->
    throw new Error("cannot resolve controller") unless controller?
    action = 'index' unless action?
    @findController(controller).toMiddleware action


  # Requires the given controller based on the "controllers path" configuration
  #
  # @param {String} controller - the controller name
  # @return {Object} the controller class
  # @api public
  findController: (controller) ->
    controllersPath = @set 'controllers path'
    raise new Error("please configure controllers path") unless controllersPath?
    require "#{controllersPath}/#{controller}"


  # Override server routing functions to autoload controller actions
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
  methods.forEach (method) =>
    @::[method] = (path) ->
      return express.HTTPServer::[method].apply(@, arguments) if arguments.length == 1 # just like old api
      cb = arguments[1]
      switch typeof cb
        when 'function' # just like old api
          express.HTTPServer::[method].apply(@, arguments)
        when 'object' # this is where we come in
          args = [method].concat toArray(arguments)
          args[2] = @buildMiddleware cb['to']
          @use(this.router) if !@.__usedRouter
          @routes._route.apply @routes, args


  # Override express-resource #route to autoload rest controller actions
  #
  #     class Users extends Controller
  #       @action index: -> @render 'index'
  #       ...
  #
  #     @resource 'users'
  #
  #@param {String|Object} name - the controller name
  #@api public
  resource: (name) -> # TODO: collection, member
    return super unless arguments.length == 1
    super name, @findController(name).toRestMiddlewares()  



module.exports = HTTPServer

