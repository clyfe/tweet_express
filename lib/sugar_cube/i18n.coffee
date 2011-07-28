# I18n with CSON files based on https://github.com/ricardobeat/node-polyglot
# TODO: refactor more


path = require 'path'
fs = require 'fs'
CSON = require 'cson'


I18n =
  languages: {}
  strings: {}
  options:
    default: 'en'
    path: '/lang'
    views: '/views'


I18n.load = (opts) ->
  if opts?
    I18n.options[k] = v for own k, v of opts
  
  # flag language existence  
  I18n.languages[I18n.options.default] = true

  throw new Error("path #{options.path} doesn't exist") unless path.existsSync(process.cwd() + I18n.options.path)
  # accept either pt-BR.json or pt.json (or cson)
  files = fs.readdirSync(process.cwd() + I18n.options.path).filter (file) -> /\w{2}(-\w{2})?\.(json|cson)$/.test file
  # load language files
  for file in files
    [country, lang] = file.match /^(\w{2})(-\w{2})?/
    CSON.parseFile process.cwd() + I18n.options.path + '/' + file, (err, data) ->
      throw new Error("failed to load language file #{file}") if err
      lang = lang.toLowerCase()
      I18n.strings[lang] = data
      I18n.strings[country.toLowerCase()] = data if lang != country
      I18n.languages[lang] = true


# sets users language
I18n.middleware = (req, res, next) ->
    return next() if req.session?.lang?
  
    acceptHeader = req.header('Accept-Language')
    I18n.languages = acceptHeader.split(/,|;/g).filter((v) -> /^\w{2}(-\w{2})?$/.test) if acceptHeader
    I18n.languages ?= []
    I18n.languages.push I18n.options.default if I18n.languages.length < 1
      
    for lang in I18n.languages
      lang = lang.toLowerCase()
      if I18n.languages[lang] and req.session?
        req.session.lang = lang
        req.session.langbase = lang.substring(0,2)
        
    # default to EN
    if req.session? and not req.session.lang?
      req.session.lang = I18n.options.default
      req.session.langbase = I18n.options.default
    
    next()


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


I18n.helpers =
  __: I18n.translate, 
  n: I18n.plural, 
  languages: I18n.languages


# TODO: parse views for __
# I18n.updateStrings


module.exports = I18n
