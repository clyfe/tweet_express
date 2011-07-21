p -> 'Hello REST'

for user in @users
  p -> user.name

form action: "/users", method: "post", ->
  input type: "text", name: "user[name]"
  input type: "submit"
