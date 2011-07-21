doctype 5
html ->
  head ->
    title -> 'Express'
    link rel: "stylesheet", href: "/stylesheets/style.css"
  body ->
    h1 -> 'Express'
  
    a href: "/", -> "Home"
    text ' | '
    a href: "/tweets", -> 'Tweets'
    text ' | '
    a href: "/users", -> 'Users'
    text ' | '
    a href: "/tags", -> 'Tags'
    text ' | '
    a href: "/admin/hi", -> 'Hi'
    
    div -> @flashes()
    div -> @body

