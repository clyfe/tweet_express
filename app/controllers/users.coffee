Controller = require 'sugar_cube/controller'
User = require 'models/user'


class Users extends Controller
  
  @scaffold User


module.exports = Users

