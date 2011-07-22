# A collection of default view helpers to make things easier by default


coffeekup = require 'coffeekup'
helper = (fn) -> -> coffeekup.compile(fn)({})


# Renders flashes
# 
#     # view.coffee
#     div -> @flashes()
# 
# @api public
exports.flashes = helper ->
  div class: "flashes", ->
    for name, content of @flash
      div class: name, -> content

