{Context, to} = require './control'

module.exports = ->
  
  @get '/', to ->
    @flash 'info', 'The flash'
    @title = 'Express'
    @render 'index'
