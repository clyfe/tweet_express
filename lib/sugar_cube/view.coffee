coffeekup = require 'coffeekup'


# Creates helper functions to be used in templates
# 
#     # helpers.coffee
#     exports.flashes = helper ->
#       div class: "flashes", ->
#         for name, content of @flash
#           div class: name, -> content
#
#     # view.coffee
#     div -> @flashes()
# 
# @fn {Function} function to be made available as a helper
# @api public
exports.helper = (fn) ->
  -> coffeekup.compile(fn)(@)

