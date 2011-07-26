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
    a href: "/admin/users", -> 'Users'
    
    div -> @flashes()
    div -> @body

