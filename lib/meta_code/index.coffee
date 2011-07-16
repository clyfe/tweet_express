# A set of metaprogramming tools to aid development, inspired by Ruby


# Use this function to enable a set of metacode tools in your class
#
#     class Controller
#       metaCode @, 'forward'
#       @forward 'req', 'param', 'session'
#
#     c = new Controller()
#     c.req = someReq
#     c.param 'x' # forwards call to "req" object
#
# @object {Object} the class (in CoffeeScript sense) to be augmented
# @modules {Strings...} the modules to bring in
# @api public
metaCode = (object, methods...) ->
  for module in methods
    meta = require("./tools/#{module}")
    object[k] = meta[k] for k of meta


module.exports = metaCode

