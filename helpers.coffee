exports.flashes = ->
  ["<div class='#{k}'>#{v}</div>" for k, v of @flash()].join()

