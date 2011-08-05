express = require 'express'
HTTPServer = require './http'


class HTTPSServer extends express.HTTPSServer
  # TODO: ?


# mixin HTTPServer methods
Object.keys(HTTPServer::).forEach (method) ->
  HTTPSServer::[method] = HTTPServer::[method]


module.exports = HTTPSServer

