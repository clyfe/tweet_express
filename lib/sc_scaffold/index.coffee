scaffoldViews = __dirname + '/views'
{View} = require 'express'


# The scaffold macro
#  
#     class Tweets extends Controller
#       @scaffold (conf) ->
#         conf.actions = ['index', 'create']
#         conf.columns = ['id', 'name', 'role]
#
# @mode {Object} the model to be scaffolded
# @config {Function}
# @api public
scaffold = (model) ->


  @action index: ->
    model.find (@err, @records) => @render 'index'
  
  
  @action new: ->
    @record = new model
  
  
  @action create: ->
    @record = new model @param 'record'
    @record.save (@err) => @redirect 'back'
  
  
  # add our scaffold views as fallbacks
  @::render = (template, fn) ->

    # Express api compatibility, just to make sure
    @[k] = v for k, v of @res._locals

    defaultViews = @res.app.set 'views'
    render_with_views_path = (path) =>
      try
        @res.app.set 'views', path
        @res.render template, @, fn, null, true
      finally
        @res.app.set 'views', defaultViews

    return @res.render(template, @, fn) if @constructor == Controller

    try # custom controller, try to scope under it's name
      render_with_views_path "#{defaultViews}/#{@constructor.controllerName()}"
    catch e
      throw e unless e.view instanceof View # e is a "Template not found" error
      try # try view from scaffold
        render_with_views_path scaffoldViews
      catch e # TODO: limit template not found
        throw e unless e.view instanceof View # e is a "Template not found" error
        @res.render template, @, fn


# augment Controllers with scaffolding
Controller = require 'sugar_cube/controller'
Controller.scaffold = scaffold


exports.scaffold = scaffold

