p -> 'Hello Controller'

for tweet in @tweets
  p -> tweet.body

form action: "/tweets", method: "post", ->
  input type: "text", name: "tweet[body]"
  input type: "submit"
