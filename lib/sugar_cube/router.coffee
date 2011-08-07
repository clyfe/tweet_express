ExpressRouter = require 'express/lib/router'
Controller = require './controller'


# MiddlewareDefinition is a helper 
# for resolving routes definitions to actual middleware functions
class DefinitionResolver

  
  # Creates a new middleware definition to be used in resolving routes
  #
  # @param {Object} app - the Server, configured with "controllers path"
  # @return {Object}
  # @api public
  constructor: (@app) ->


  # Returns a Connect middleware, given a route definition
  #
  # @param {Function|String|Object} to - the middleware definition
  # @return {Function} a Connect middleware (that resolves to the specified Controller)
  # @api public
  toMiddleware: (to) ->
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
    controllersPath = @app.set 'controllers path'
    raise new Error("please configure controllers path") unless controllersPath?
    require "#{controllersPath}/#{controller}"


# A router with advanced routing dsl capabilities
class Router extends ExpressRouter
  
  
  # Construct with definition resolver for advanced routing dsl capabilities
  constructor: ->
    super
    @definitionResolver = new DefinitionResolver @app


  # Route `method`, `path`, and optional middleware
  # to the callback `fn`.
  # 
  # @param {String} method
  # @param {String} path
  # @param {Function} ...
  # @param {Function|String|object} cb - connect middleware or middleware definition as defined by `DefinitionResolver` class
  # @return {Router} for chaining
  # @api private
  _route: (method, path, cb) ->
    switch typeof cb
      when 'function' then super # just like old api
      when 'object' # this is where we come in
        fn = @definitionResolver.toMiddleware cb['to']
        super(method, path, fn)
        
        
  # X
  #
  #     /users/:id
  #
  #     @urlFor controller: 'users', id: 10, page: 12
  #     /users/10?page=12
  #
  urlFor: (opts) ->
    {method, controller, action} = opts
    

exports.DefinitionResolver = DefinitionResolver
exports.Router = Router

