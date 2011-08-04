doctype 5
html ->
  head ->
    meta charset: "utf-8"
    meta 'http-equiv': "Content-Type", content: "text/html; charset=utf-8"
  
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

    script src: "/browserify.js", type: "text/javascript"
