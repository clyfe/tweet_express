mongoose = require 'mongoose'

TweetSchema = new mongoose.Schema
  date: {type: Date, default: Date.now}
  author: {type: String, default: 'Anon'}
  body: {type: String, default: 'ohai!'}

module.exports = mongoose.model 'Tweet', TweetSchema

