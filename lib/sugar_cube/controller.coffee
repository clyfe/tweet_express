metaCode = require 'meta_code'
{Set} = require 'sugar_cube/data_structures'


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
  @forward 'req', 'param', 'app', 'flash'
  @forward 'res', 'redirect', 'cookie', 'clearCookie', 'partial', 'download'
  
  # a nifty introspection thingie to return the controller name
  #
  # @api public
  @controllerName: -> 
    @_controllerName ?= @toString().match(/function ([^\(]+)/)[1].toLowerCase()
  
  # Creates a context instance, populated with req, res, next
  #
  # @req {Object} the router-provided Express req object
  # @req {Object} the router-provided Express res object
  # @next {Object} the in-router-provided next middleware, (error catcher etc.)
  # @api public
  constructor: (@req, @res, @next) ->
    this.session = @req.session
  
  # A smart way to handle errors.
  #
  #     @get '/', to ->
  #       Tweet.find (@err, @tweets) => @render 'index'
  #  
  # @err {Object} the error to be forwarded to next
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
  # @template {Object} template name/path (index, index.eco etc.)
  # @fn {Object} optional callback, see Express.Response#render
  # @api public
  render: (template, fn) ->
    
    # Express api compatibility, just to make sure
    @[k] = v for k, v of @res._locals
    
    defaultViews = @res.app.set 'views'
    @layout = "#{defaultViews}/layouts/application" unless @layout?
    return @res.render(template, @, fn) if @constructor == Controller
    
    # custom controller, try to scope under it's name
    try
      @res.app.set 'views', "#{defaultViews}/#{@constructor.controllerName()}"
      @res.render template, @, fn, null, true
      @res.app.set 'views', defaultViews
    catch e # TODO: limit template not found
      @res.app.set 'views', defaultViews
      @res.render template, @, fn
  
  # Adnotation helper for action definitions.
  # Serves to differentiate between controller actions and regullar (private) methods.
  #   
  #     class Users extends Controller
  #       @action index: ->
  #         @log_req()
  #         User.find (@err, @users) => @render 'users/index'
  #       log_req: -> # regullar "private" method, cannot be called as an action
  #         req = new Request req: @req
  #         req.save (@err) => console.log 'req logged'
  # 
  # @action {Object} the router-provided Express req object
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
  #     @get '/users', Users.to_middleware 'index' # executes index action
  #     
  #     # uses Sessions controller as execution context for the callback function
  #     @get '/login', Sessions.to_middleware -> @render 'login_form'
  # 
  # @action {Object}  the router callback function or action-defining string
  # @api public
  @toMiddleware: (action) ->
    switch typeof action
      when 'function'
        @wrapErrorsMiddleware (req, res, next) => action.call new @(req, res, next)
      when 'string'
        throw new Error("#{action} is not a controller action") unless action in @actions
        @wrapErrorsMiddleware (req, res, next) => new @(req, res, next)[action]()
      else
        throw new Error("unknown action #{cb}, only functions and strings valid actions")
          
  # Returns a express-resources conforming object, with the required actions
  #
  #     class Users extends Controller
  #       @action index: -> @render 'index'
  #       ...
  # 
  #     Users.toRestMiddlewares() == {index: -> @render 'index', ...}
  # 
  # @api public
  @toRestMiddlewares: ->
    rest = {}
    rest[action] = @toMiddleware(action) for action in @actions
    rest

  # Wraps a middleware in an error catching middlware that forwards any thrown errors to next()
  #
  # @api private
  @wrapErrorsMiddleware: (fn) ->
    (req, res, next) ->
      try
        fn(req, res, next)
      catch err
        next(err)


module.exports = Controller

