# A set of useful data structures


# A Set is an array with unique elements
#
# @api private
class Set extends Array
  push: (x) -> super x unless x in @
  
exports.Set = Set
