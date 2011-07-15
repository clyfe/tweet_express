utils = require('express/lib/utils')


# Forward method calls to certain properties.
#
#     @forward 'req', 'param', 'session'
#
# same as
#
#     param: -> @req.param.apply @req, arguments
#     session: -> @req.session.apply @req, arguments
#
# @object {String} the name of the property to forward calls to
# @methods {Strings...} the methods to be wired
# @api public
forward = ->
  args = utils.toArray(arguments)
  object = args.shift()
  proto = @::
  for m in args
    do (m) ->
      proto[m] = -> @[object][m].apply @[object], arguments


exports.forward = forward
