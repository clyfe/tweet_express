mongoose = require 'mongoose'

TagSchema = new mongoose.Schema
  name: {type: String, default: 'tag'}
  rank: {type: Number, default: 0}

module.exports = mongoose.model 'Tag', TagSchema

