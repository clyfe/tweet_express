# A set of metaprogramming tools to aid development, inspired by Ruby


utils = require('express/lib/utils')


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
metaCode = ->
  args = utils.toArray(arguments)
  object = args.shift()
  for module in args
    meta = require("./tools/#{module}")
    object[k] = meta[k] for k of meta


module.exports = metaCode

