mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
  name: {type: String, default: 'Anon'}
  password: {type: String, default: 'ohai!'}

module.exports = mongoose.model 'User', UserSchema

