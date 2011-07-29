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
# @param {Function} fn - function to be made available as a helper
# @return {Function) a function that can be used as a helper in CoffeeKup views
# @api public
exports.helper = (fn) ->
  -> coffeekup.compile(fn)(@)

