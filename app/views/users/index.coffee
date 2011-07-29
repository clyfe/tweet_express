p -> 'Hello Namespaces, REST routing & Scaffolding'

for record in @records
  p -> record.name

form action: "/users", method: "post", ->
  input type: "text", name: "user[name]"
  input type: "submit"
