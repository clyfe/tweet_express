# Copy into object all properties from module onto self
#
#     Macros =
#       delegate: (to, what) -> 
#         @[what] = @[to][what].call @[to], arguments
#
#     class Application extends Controller
#       metaCode @, 'module'
#       @extend Macros
#       @delegate 'req', 'userId'
#       index: -> console.log @userId()
#
# @objects {Objects...} the objects to extend with
# @api public
extend = (objects...) ->
  for object in objects
    for name, property of object
      @[name] = property


# Copy into object all properties from module onto the prototype
#
#     Authentication =
#       currentUser: (cb) -> 
#         User.find @session('userId'), (err, user) ->
#           user = new User() if err
#           cb(user)
#
#     Authorization =
#       authorize: (role, cb) ->
#         @currentUser (user) ->
#           throw new Error('Not Authorized') unless user.role == role
#           cb()
#
#     class Tweets extends Controller
#       metaCode @, 'module'
#       @include Authentication, Authorization
#       show:
#         @authorize 'admin', =>
#           Tweet.find @params 'id', (@err, @tweet) => @render 'show'
#
# @objects {Objects...} the objects to mix in
# @api public
include = (objects...) ->
  proto = @::
  for object in objects
    for name, property of object
      proto[k] = p


exports.include = include

