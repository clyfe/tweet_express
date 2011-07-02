mongoose = require 'mongoose'

mongoose.connect('mongodb://localhost/ct');

TweetSchema = new mongoose.Schema
  date: {type: Date, default: Date.now}
  author: {type: String, default: 'Anon'}
  body: {type: String, default: 'ohai!'}

exports.Tweet = mongoose.model('Tweet', TweetSchema);
