# Copy into object all properties from module onto the prototype
#
#     Authentication =
#       currentUser: (cb) -> 
#         User.find @session('userId'), (err, user) ->
#           user = User.new if err
#           cb(user)
#
#     Authorization =
#       authorize: (role, cb) ->
#         @currentUser (user) ->
#           throw new Error('Not Authorized') unless currentUser.role == role
#           cb()
#
#     class Tweets extends Controller
#       metaCode @, 'module'
#       @include Authentication, Authorization
#       show:
#         @authorize 'admin', ->
#           Tweet.find @params 'id', (@err, @tweet) => @render 'show'
#
# @objects {Objects...} the objects to mix in
# @api public
include = (objects...) ->
  proto = @::
  for object in objects
    for k, p of object
      do (k, p) ->
        switch typeof p
        when 'function'
          proto[k] = -> p.apply @, arguments
        else
          proto[k] = p


# Copy into object all properties from module onto self
#
#     Macros =
#       delegate: (to, what) -> @[what] = @[to][what]
#
#     class Application extends Controller
#       metaCode @, 'module'
#       @extend Macros
#       @delegate 'req', 'userId'
#       index: -> console.log @userId
#
# @objects {Objects...} the objects to extend with
# @api public
extend = (objects...) ->
  resciever = @
  for object in objects
    for k, p of object
      do (k, p) ->
        switch typeof p 
        when 'function'
          resciever[k] = -> p.apply resciever, arguments
        else
          resciever[k] = p


exports.include = include

