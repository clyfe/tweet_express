path = require 'path'
express = require 'express'

require.paths.unshift path.join(__dirname, 'app')
require.paths.unshift path.join(__dirname, 'lib')

module.exports = app = express.createServer()

require('config').call app
require('routes').call app
app.helpers require('helpers')

if require.main == module
  app.listen 4000
  console.log "Express server listening on port %d", app.address().port

