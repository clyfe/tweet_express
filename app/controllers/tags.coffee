Controller = require 'sugar_cube/controller'
Tag = require 'models/tag'


class Tags extends Controller
  
  @scaffold Tag


module.exports = Tags

