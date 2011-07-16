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
    for m of object
      do (m) ->
        switch typeof action
        when 'function'
          proto[m] = -> object[m].apply @, arguments
        else
          proto[m] = object[m]


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
    for m of object
      do (m) ->
        switch typeof action
        when 'function'
          resciever[m] = -> object[m].apply resciever, arguments
        else
          resciever[m] = object[m]


exports.include = include

