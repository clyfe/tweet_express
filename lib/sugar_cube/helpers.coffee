# A collection of default view helpers to make things easier by default


###
Renders flashes

    # view.eco
    <%- @flashes() %>

@api public
###
exports.flashes = ->
  '<div class="flashes">' +
  ["<div class='#{k}'>#{v}</div>" for k, v of @flash].join() + 
  '</div>'


###
View helpers via CoffeeKup

    # view.eco
    <%-@ck -> div class: 'big' %>

@api public
###
coffeekup = require 'coffeekup'
exports.ck = coffeekup.render
