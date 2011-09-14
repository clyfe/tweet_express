metaCode = require 'meta_code'
{View} = require 'express'


# A Set is an array with unique elements
#
# @api private
class Set extends Array
  push: (x) -> super x unless x in @


# A controller class that can be used:
# 1. as context in wich router functions are executed
# 2. as a base class for your custom controllers
# 
# Provides some sugar to common methods "params", "render" etc.
# Routes are executed on this class's instances, 
# so they can call @req, @res, @param, @redirect, @render etc.
# 
# Route example
# 
#     @get '/', to ->
#       @title = 'Hello'
#       @render 'index'
#   
# Controller example
# 
#     @get '/tweets', to 'tweets#index'
#   
#     class Tweets extends Controller
#       @action index: ->
#         @title = 'Hello'
#         @render 'index'
# 
# @api public
class Controller
  
  
  # use forward metacode helpers
  metaCode @, 'forward'


  # some sugar to access common methods faster
  @forward 'req', 'param', 'flash'
  @forward 'res', 'redirect', 'cookie', 'clearCookie', 'partial', 'download'
  
  
  # A nifty introspection thingie to return the controller name
  #
  # @api public
  @controllerName: -> 
    @_controllerName ?= @toString().match(/function ([^\(]+)/)[1].toLowerCase()
  
  
  # Default layout. This can be configured per controller
  #
  #     class Users extends Controller
  #       @layout: 'users' # ie. views/layouts/users.coffee
  #
  # Default value is "application" ie. "views/layouts/application.coffee"
  #
  # @api public
  @layout: 'application'
  
  
  # Creates a context instance, populated with req, res, next
  #
  # @param {Object} req - the router-provided Express req object
  # @param {Object} res - the router-provided Express res object
  # @next {Function} next - the in-router-provided next middleware, (error catcher etc.)
  # @api public
  constructor: (@req, @res, @next) ->
  
    # copy needed properties, only functions can be forwarded
    @app = @req.app
    @session = @req.session
    
    # default layout, this can be changed at action level
    defaultViews = @res.app.set 'views'
    @layout = "#{defaultViews}/layouts/#{@constructor.layout}"
  
  
  # A smart way to handle errors. When the `@err` property is setted,
  # the error is automatically thrown
  #
  #     @get '/', to ->
  #       Tweet.find (@err, @tweets) => @render 'index'
  #  
  # @param {Object} err - the error to be forwarded to next
  # @api public
  @::__defineSetter__ 'err', (err) -> throw err if err
  
  
  # Renders a template via Express's res#render, with the following additions:
  # * providing the locals to the current (controller instance) context
  # * searches for a template in ViewsRoot/ControllerName/* first, with fallbacks to ViewsRoot/ etc.
  #
  #     # app.coffee
  #     @get '/', to ->
  #       @title = 'Express'
  #       @render 'index'
  #
  #     # index.coffee
  #     h1 -> @title
  #
  # @param {Object} template - template name/path (index, index.eco etc.)
  # @param {Object} fn - optional callback, see Express.Response#render
  # @api public
  render: (template, fn) ->

    # Express api compatibility, just to make sure
    @[k] = v for k, v of @res._locals

    # router function
    return @res.render(template, @, fn) if @constructor == Controller

    defaultViews = @res.app.set 'views'
    render_with_views_path = (path) =>
      try
        @res.app.set 'views', path
        @res.render template, @, fn, null, true
      finally
        @res.app.set 'views', defaultViews

    try # custom controller, try to scope under it's name
      render_with_views_path "#{defaultViews}/#{@constructor.controllerName()}" # TODO: module path
    catch e
      throw e unless e.view instanceof View # e is a "Template not found" error
      @res.render template, @, fn   

    
  # Adnotation helper for action definitions.
  # Serves to differentiate between controller actions and regullar (private) methods.
  #   
  #     class Users extends Controller
  #       @action index: ->
  #         @log_req()
  #         User.find (@err, @users) => @render 'users/index'
  #       log_req: -> # regullar method, cannot be called as an action
  #         req = new Request req: @req
  #         req.save (@err) => console.log 'req logged'
  # 
  # @param {Object} action - the router-provided Express req object
  # @api public
  @action: (action) ->
    @actions = new Set() unless @hasOwnProperty 'actions'
    for k, v of action
      @actions.push k
      @::[k] = v
  
  
  # Returns a Connect conforming callback function, that runs on the calling controller's instances.
  #
  #     class Users extends Controller
  #       @action index: -> @render 'index'
  #
  #     class Sessions extends Controller
  #    
  #     @get '/users', Users.middleware 'index' # executes index action
  #     
  #     # uses Sessions controller as execution context for the callback function
  #     @get '/login', Sessions.middleware -> @render 'login_form'
  # 
  # @param {Object} action - the router callback function or action-defining string
  # @return {Function} a Connect middleware
  # @api public
  @middleware: (action) ->
    switch typeof action
      when 'function'
        @wrapErrorsMiddleware (req, res, next) => action.call new @(req, res, next)
      when 'string'
        throw new Error("#{action} is not a controller action") unless action in @actions
        @wrapErrorsMiddleware (req, res, next) => new @(req, res, next)[action]()
      else
        throw new Error("unknown action #{action}, only functions and strings represent valid actions")
          
          
  # Extracts all the middlewares from this controller into a hash (js object)
  # Used as sugar paired with express-resources
  #
  #     class Users extends Controller
  #       @action index: -> @render 'index'
  #       ...
  # 
  #     Users.middlewares() == {index: -> @render 'index', ...}
  # 
  # @return {Object} an object of Connect middlewares
  # @api public
  @middlewares: ->
    rest = {}
    rest[action] = @middleware(action) for action in @actions
    rest


  # Wraps a middleware in an error catching middlware that forwards any thrown errors to next()
  #
  # @param {Function} fn - a Connect middleware
  # @return {Function} a Connect middleware
  # @api private
  @wrapErrorsMiddleware: (fn) ->
    (req, res, next) ->
      try
        fn(req, res, next)
      catch err
        next(err)


module.exports = Controller

