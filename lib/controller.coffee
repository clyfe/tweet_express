utils = require('express/lib/utils')


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
 
  # A Set is an array with unique elements
  #
  # @api private
  class Set extends Array
    push: (x) -> super x unless x in @

  # Internal utility to forward method calls to certain properties.
  #
  #     @forward 'req', 'param', 'session'
  #
  # same as
  #
  #     param: -> @req.param.apply @req, arguments
  #
  # @object {String} the name of the property to forward calls to
  # @methods {Strings...} the methods to be wired
  # @api private
  @forward: -> 
    args = utils.toArray(arguments)
    object = args.shift()
    proto = @::
    for m in args
      do (m) ->
        proto[m] = -> @[object][m].apply @[object], arguments
    
  # some sugar to access common methods faster
  # TODO: document these ?
  @forward 'req', 'param', 'app', 'session', 'flash'
  @forward 'res', 'redirect', 'cookie', 'clearCookie', 'partial', 'download'
  
  # Creates a context instance, populated with req, res, next
  #
  # @req {Object} the router-provided Express req object
  # @req {Object} the router-provided Express res object
  # @next {Object} the in-router-provided next middleware, (error catcher etc.)
  # @api public
  constructor: (@req, @res, @next) ->
  
  # A smart way to handle errors.
  # Ex.
  #
  #     @get '/', to ->
  #       Tweet.find (@err, @tweets) => @render 'index'
  #  
  # @err {Object} the error to be forwarded to next
  # @api public
  @::__defineSetter__ 'err', (err) ->
    throw err if err
  
  # Renders a template via Express's res#render, 
  # only it does so by providing the locals to the current context.
  #
  #     # app.coffee
  #     @get '/', to ->
  #       @title = 'Express'
  #       @render 'index'
  #
  #     # index.eco
  #     <h1><%= @title %></h1>
  #
  # @template {Object} template name/path (index, index.eco etc.)
  # @fn {Object} optional callback, see Express.Response#render
  # @api public
  render: (template, fn) -> 
    @[k] = v for k, v of @res._locals # Express api compatibility
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
  #     @get '/users', Users.to_middleware 'index'
  #     @get '/login', Sessions.to_middleware -> @render 'login_form'
  # 
  # @action {Object}  the router callback function or action-defining string
  # @api public
  @toMiddleware: (action) ->
    switch typeof action
      when 'function'
        (req, res, next) => action.call(new @(req, res, next))
      when 'string'
        throw new Error("#{action} is not a controller action") unless action in @actions
        (req, res, next) => (new @(req, res, next))[action]()
      else
        throw new Error("unknown action #{cb}, only functions and strings valid actions")


module.exports = Controller

