utils = require('express/lib/utils')

###
A controller class that can be used:
1. as context in wich router functions are executed
2. as a base class for your custom controllers

Provides some sugar to common methods "params", "render" etc.
Routes are executed on this class's instances, 
so they can call @req, @res, @param, @redirect, @render etc.

Route example

  @get '/', to ->
    @title = 'Hello!'
    @render 'index'
    
Controller example

  @get '/tweets', to 'tweets#index'
  @get '/tweets/hi', to 'tweets#hi'
  
  class Tweets extends Controller
    index: ->
      @title = 'Hello'
      @render 'index'
    hi: ->
      @title = 'Hi'
      @render 'hi'

@api public
###
class Controller

  # a Set is an array with unique elements
  class Set extends Array
    push: (x) -> super x unless x in @

  ###
  Internal utility to forward method calls to certain properties.
  
      @forward 'req', 'param', 'session'
  
  same as
  
      param: -> @req.param.apply @req, arguments
  
  @object {String} the name of the property to forward calls to
  @methods {Strings...} the methods to be wired
  @api public
  ###
  @forward: -> 
    args = utils.toArray(arguments)
    object = args.shift()
    proto = @::
    for m in args
      do (m) ->
        proto[m] = -> @[object][m].apply @[object], arguments
    
  # some sugar to access common methods faster
  @forward 'req', 'param', 'app', 'session', 'flash'
  @forward 'res', 'redirect', 'cookie', 'clearCookie', 'partial', 'download'
  
  ###
  Creates a context instance, populated with req, res, next

  @req {Object} the router-provided Express req object
  @req {Object} the router-provided Express res object
  @api public
  ###
  constructor: (@req, @res, @next) ->
    
  ###
  A smart way to handle errors.
  Ex.
  
    @get '/', to ->
      Tweet.find (@err, @tweets) => @render 'index'
    
  @err {Object} the error to be forwarded to next
  @api public
  ###
  @::__defineSetter__ 'err', (err) ->
    throw err if err

    
  ###
  Renders a template via Express's res#render, 
  only it does so by providing the locals to the current context.
  
      # app.coffee
      @get '/', to ->
        @title = 'Express'
        @render 'index'

      # index.eco
      <h1><%= @title %></h1>
      
  @req {Object} the router-provided Express req object
  @req {Object} the router-provided Express res object
  @api public
  ###
  render: (template, fn) -> 
    @[k] = v for k, v of @res._locals # Express api compatibility
    @res.render template, @, fn
  
  ###
  Adnotation helper for action definitions.
  Serves to differentiate between controller actions and regullar (private) methods.
  
     class Users extends Controller
       @action index: ->
         @log_req()
         User.find (@err, @users) => @render 'users/index'
       log_req: -> # regullar "private" method
         req = new Request req: @req
         req.save (@err) => console.log 'req logged'
  
  @action {Object} the router-provided Express req object
  @api public
  ###
  @action: (action) ->
    @actions ?= new Set
    for k, v of action
      @actions.push k
      @::[k] = v
      
  @dispatch: (action, req, res, next) ->
    throw new Error("#{action} is not a controller action") unless action in @actions
    controller = new @(req, res, next)
    controller[action]()


module.exports = Controller

