ExpressRouter = require 'express/lib/router'
Controller = require './controller'


# A router with advanced routing dsl capabilities
class Router extends ExpressRouter


  constructor: ->
    super
    
    # paths to controller actions
    @to = [] # @to.users.create(id: 10)
    
    # named paths
    @at = [] # @at.download_file(name: 'file.txt')
  

  # Route `method`, `path`, and optional middleware
  # to the callback defined by `cb`.
  # 
  # @param {String} method
  # @param {String} path
  # @param {Function} ...
  # @param {Function|String|Object} cb - connect middlewares or middleware definition as defined by `DefinitionResolver` class
  # @return {Router} for chaining
  # @api private
  _route: (method, path) ->
    definition = arguments[arguments.length - 1]
    return super if arguments.length < 3 or typeof definition != 'object' # just like old api
    {to, as} = definition
    fn = switch typeof to
      when 'function'
        Controller.middleware to
      when 'string'
        throw new Error("string route definition must be in the form 'controller#action'") unless to.match /(\w_)+#(\w_)+/
        [controller, action] = to.split '#'
        @_resolveControllerAction controller, action
      when 'object'
        {controller, action} = to
        @_resolveControllerAction controller, action
      else
        throw new Error("unknown route endpoint #{to}")
    super method, path, fn


  # Validates the existence of controller and returns the resolved middleware
  # 
  # @param {String} controller - the controller name
  # @param {String} action - the controller action (or skip if rest)
  # @return {Function} a Connect middleware (that resolves to the given controller and action)
  # @api private
  _resolveControllerAction: (controller, action) ->
    throw new Error("cannot resolve controller") unless controller?
    action = 'index' unless action?
    @findController(controller).middleware action


  # Requires the given controller based on the "controllers path" configuration
  #
  # @param {String} controller - the controller name
  # @return {Object} the controller class
  # @api public
  findController: (controller) ->
    controllersPath = @app.set 'controllers path'
    throw new Error("please configure controllers path") unless controllersPath?
    require "#{controllersPath}/#{controller}"
  
  
  # Return a url given a controller and an action, and optional params
  # TODO: steal from https://github.com/josh/rack-mount/blob/master/lib/rack/mount/route_set.rb
  #
  #     Given a route "/users/:id"
  #
  #     @urlFor controller: 'users', id: 10, page: 12
  #     /users/10?page=12
  #
  url: (opts) ->
    throw new Error('controller must be specified') unless opts.controller?
    controller = opts.controller
    action = opts.action || 'index'
    method = opts.action || 'get'
    

module.exports = Router

