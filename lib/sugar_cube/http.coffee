express = require 'express'
Router = require './router'


# A server smarter than the Express one
class HTTPServer extends express.HTTPServer


  # Override init to use our custom router
  init: ->
    super
    @routes = new Router @


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
    return super unless arguments.length == 1 # just like old api
    super name, @routes.findController(name).middlewares()


module.exports = HTTPServer

