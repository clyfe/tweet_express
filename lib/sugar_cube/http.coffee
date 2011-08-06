express = require 'express'
{toArray} = require 'express/lib/utils'
router = require 'express/lib/router'
methods = router.methods.concat('del', 'all')
HTTPServer = require './http'
{DefinitionResolver} = require './router'

# A server smarter than the Express one
class HTTPServer extends express.HTTPServer


  # Override init to create paths property on router
  init: ->
    super
    @router.paths = {}
    @definitionResolver = new DefinitionResolver @
  

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
  methods.forEach (method) ->
    HTTPServer::[method] = (path) ->
      return express.HTTPServer::[method].apply(@, arguments) if arguments.length == 1 # just like old api
      cb = arguments[1]
      switch typeof cb
        when 'function' # just like old api
          express.HTTPServer::[method].apply(@, arguments)
        when 'object' # this is where we come in
          args = [method].concat toArray(arguments)
          args[2] = @definitionResolver.toMiddleware cb['to']
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
    super name, @definitionResolver.findController(name).toRestMiddlewares()
  
  #
  urlFor: (opts) ->
    {method, controller, action} = opts

module.exports = HTTPServer

