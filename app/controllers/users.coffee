Controller = require 'sugar_cube/controller'
User = require 'models/user'


class Users extends Controller
  
  @action index: ->
    User.find (@err, @users) => @render 'users/index'
    
  @action create: ->
    @user = new User @param 'user'
    @user.save (@err) => @redirect 'back'


module.exports = Users

