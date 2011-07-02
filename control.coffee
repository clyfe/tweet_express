###
Utility file that provides mostly syntactic sugar
###


utils = require('express/lib/utils')


###
A context in wich router functions are executed.
Provides some sugar to common methods "params", "render" etc.

@api public
###
class Context

  ###
  Forwards method calls to certain properties
  
  @object {String} the name of the property to forward calls to
  @methods {Strings...} the methods to be wired
  @api public
  ###
  @forward: -> 
    args = utils.toArray(arguments)
    object = args.shift()
    (@::[m] = -> @[object][m].apply @[object], arguments) for m in args
    
  # some sugar to access common methods faster
  @forward 'req', 'param'
  @forward 'res', 'redirect'

  ###
  Creates a context instance, populated with req and res

  @req {Object} the router-provided Express req object
  @req {Object} the router-provided Express res object
  @api public
  ###
  constructor: (@req, @res) ->
    @[k] = req[k] for k in ['app', 'session', 'flash']
    @[k] = res[k] for k in ['cookie', 'clearCookie', 'partial', 'download']
    
  ###
  Renders a template via Express's res#render, 
  only it does so by providing the locals to the current context
  
      # app.coffee
      {to, Context} = require './control'
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
Returns a function that conforms to Express router api, that wraps the provided fn function.
fn is executed in a Context object instance, at req time

    # app.coffee
    {to, Context} = require './control'
    @get '/', to ->
      @title = 'Express'
      @render 'index'

    # index.eco
    <h1><%= @title %></h1>

@fn {Function} the router callback function to be executed 
@api public
###
to = (fn) -> 
  (req, res) -> fn.call(new Context req, res)


exports.Context = Context
exports.to = to

