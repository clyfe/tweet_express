Controller = require 'controller'

###
Returns a function that conforms to Express router api, that wraps the provided "cb" function or controller.
If "cb" is a function, it is executed in a Context object instance, at req time.
If it's a controller it is executed in the controller object.

Route function callback example:

    # routes.coffee
    @get '/', to ->
      @title = 'Express'
      @render 'index'

    # index.eco
    <h1><%= @title %></h1>

Controller callback example:

    # routes.coffee
    @get '/', to 'tweets#index'

@cb {Function|String} the router callback function or controller string to be executed 
@api public
###
to = (cb) ->
  
  switch typeof cb
    when 'function'
      fn = (req, res, next) -> cb.call(new Controller req, res, next)
    when 'string'
      [controller, action] = cb.split '#'
      controller = require "controllers/#{controller}"
      fn = (req, res, next) -> controller.dispatch action, req, res, next
    else
      throw new Error("unknown route endpoint #{cb}")
  
  (req, res, next) -> 
    try fn(req, res, next)
    catch err
      next(err)


module.exports = to

