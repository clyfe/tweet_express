# A collection of default view helpers to make things easier by default


###
Renders flashes

    # view.coffee
    div -> @flashes()

@api public
###
exports.flashes = ->
  div class: "flashes", ->
    for name, content of @flash
      div class: name, -> content

