
###
Renders flashes

    # view.eco
    <%- @flashes() %>

@api public
###
exports.flashes = ->
  '<div class="flashes">' +
  ["<div class='#{k}'>#{v}</div>" for k, v of @flash()].join() + 
  '</div>'
