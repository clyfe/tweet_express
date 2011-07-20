path = require 'path'
express = require 'express'
require 'express-resource'
require 'express-namespace'
mongoose = require 'mongoose'

require.paths.unshift path.join(__dirname, 'app')
require.paths.unshift path.join(__dirname, 'lib')

require 'sc_scaffold'

module.exports = app = express.createServer()

require('config').call app
mongoose.connect app.set('mongoose url')
require('routes').call app
app.helpers require 'sugar_cube/helpers'
app.helpers require 'helpers'

if require.main == module
  app.listen 4000
  console.log "Express server listening on port %d", app.address().port

