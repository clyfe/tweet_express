# I18n with CSON files based on https://github.com/ricardobeat/node-polyglot
# TODO: refactor more


path = require 'path'
fs = require 'fs'
CSON = require 'cson'


debug = (str) -> I18n.options.debug && console.log "[I18n] #{str}"

I18n = (opts) ->

  #default options
  options = I18n.options = default: 'en', path: '/lang', views: '/views', debug: false

  # override defaults
  options[key] = val for own key, val of opts
  
  # flag language existence  
  I18n.languages[options.default] = true

  if path.existsSync(process.cwd() + options.path)
    # accept either pt-BR.json or pt.json
    files = fs.readdirSync(process.cwd() + options.path).filter (file) -> /\w{2}(-\w{2})?\.(json|cson)$/.test file
    # load language files
    for file in files
      [country, lang] = file.match /^(\w{2})(-\w{2})?/
      data = CSON.parseFile process.cwd() + options.path + '/' + file, (err, obj) ->
        if err
          debug "failed to load language file #{file}"
        else
          lang = lang.toLowerCase()
          I18n.strings[lang] = data
          I18n.strings[country.toLowerCase()] = data if lang != country
          I18n.languages[lang] = true
          debug "loaded #{file}"
  else
    debug "path #{options.path} doesn't exist"

  # sets users language
  return (req, res, next) ->
    if req.session?.lang?
      debug "current language: #{req.session.lang}"
      next()
      return
  
    acceptHeader = req.header('Accept-Language')
    languages = acceptHeader.split(/,|;/g).filter((v) -> /^\w{2}(-\w{2})?$/.test) if acceptHeader
    languages ?= []  
    debug "accepted languages: "+languages.join(', ')
      
    if languages.length < 1
      languages.push I18n.options.default
      debug "empty Accept-Language header, reverting to default"
      
    for lang in languages
      lang = lang.toLowerCase()
      if I18n.languages[lang] and req.session?
        req.session.lang = lang.toLowerCase()
        req.session.langbase = lang.toLowerCase().substring(0,2)
        
    # default to EN
    if req.session? and not req.session.lang?
      req.session.lang = I18n.options.default
      req.session.langbase = I18n.options.default
    
    next()


# keep track of active languages
I18n.languages = {}
I18n.strings   = {}


# where the real thing happens
I18n.translate = (str) -> I18n.strings[@session?.lang]?[str] or I18n.strings[@session?.langbase]?[str] or str
  
n_replace = (str, n) -> str.replace /%s/g, n  
# ([zero], single, plural, n)
I18n.plural = (zero, single, plural, _n) ->
  if not _n?
    _n = n = plural 
    if n > 1 then n = 1
    else if n < 2 then n = 0
  else
    n = _n
    if n > 2 then n = 2
    else if n < 1 then n = 0
  n_replace arguments[n], _n
  
I18n.setLanguage = (session, lang) ->
  if I18n.languages[lang]
    session.lang = lang
    session.langbase = lang.substring(0,2)
        
collectStrings = (contents, fn) ->
  pattern = new RegExp ///
    #{fn}\(              # opening parenthesis
    (["'])               # opening quote
    ((?:(?!\1)[^\\]|\\.)*) # string
    \1                   # closing quote
    \)                   # closing parenthesis
    ///g
  strings = []
  while m = pattern.exec contents
    strings.push m[2] if m[2] and m[2].length > 1
  strings


devStrings = {}

# parse views for __
I18n.updateStrings = (fn) ->

  fn ?= '__'

  viewsPath = process.cwd() + I18n.options.views

  if not path.existsSync(viewsPath)
    debug "no views found in #{viewsPath}"
    return
    
  views = fs.readdirSync(viewsPath).filter (file) -> /\w+.(htm|html|ejs|tpl)$/.test file
  
  for view in views
    debug "collecting strings from #{view}"
    contents = fs.readFileSync("#{viewsPath}/#{view}").toString()
    devStrings[string] = 1 for string in collectStrings(contents, fn)

  files = fs.readdirSync( process.cwd() + I18n.options.path ).filter (file) ->
    debug "loading language file #{file}"
    # accept either pt-BR.json or pt.json
    /\w{2}(-\w{2})?\.json$/.test file
    
  for file in files
    
    # TODO: check modification date to avoid unnecessary updates
    filePath = process.cwd() + I18n.options.path + '/' + file
    try
      strings = JSON.parse fs.readFileSync(filePath, 'utf8')
    catch e
      strings = {}
    
    # add new strings
    for s, v of devStrings
      strings[s] = "" unless strings[s]?
        
    for string, translation of strings
      delete strings[string] unless devStrings[string]
    
    fs.writeFileSync(filePath, JSON.stringify(strings, null, "\t"), 'utf8')
    debug "updated strings in #{file}"


module.exports = I18n
