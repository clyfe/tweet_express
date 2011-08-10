# TODO: ISO lang-COUNTRY, consider country etc


path = require 'path'
fs = require 'fs'
lingo = require 'lingo'
Language = lingo.Language
CSON = require 'cson'


# I18n utilities that build on lingo module
#
# @api public
I18n =
  options:
    default: 'en'
    path: '/lang'


# Load translation dictionaries from `I18n.options.path`
#
#     I18n.load default: 'es', path: __dirname + '/langs'
#
# @param {Object} opts - options to set as default
# @api public
I18n.load = (opts) ->
  @options[k] = v for own k, v of opts if opts?
  
  throw new Error("path #{@options.path} doesn't exist") unless path.existsSync(process.cwd() + @options.path)
  
  # accept either pt-BR.json or pt.json (or cson)
  files = fs.readdirSync(process.cwd() + @options.path).filter (file) -> /\w{2}(-\w{2})?\.(json|cson)$/.test file
  for file in files
    [lang, country] = file.match /^(\w{2})(-\w{2})?/
    language = new Language lang.toLowerCase()
    language.translations = CSON.parseFileSync(process.cwd() + @options.path + '/' + file)
  
  new Language(@options.default) unless lingo[@options.default] # ensure default language existence


# Middleware to set the user language from `Accept-Language` header, unless it exists
#
# @api public
I18n.middleware = (req, res, next) ->
    return next() if req.session?.lang?
  
    acceptHeader = req.header('Accept-Language')
    langs = acceptHeader.split(/,|;/g).filter((v) -> /^\w{2}(-\w{2})?$/.test) if acceptHeader
    langs ?= []
    langs.push I18n.options.default if langs.length < 1
      
    for lang in langs
      lang = lang.toLowerCase()
      req.session.lang = lang if lingo[lang]? and req.session?
        
    # default to EN
    req.session.lang = I18n.options.default if req.session? and not req.session.lang?
    
    next()


# Translates a string and iterpolates params, according to dictionaries
#
#     # en.cson
#     hello_user: "Hello {username}"
#
#     # some_view.coffee
#     @t 'hello_user', username: 'Paul'
#
# @param {Object} opts - options to set as default
# @api public
translate = (str, params) -> 
  lang = @session?.lang or I18n.options.default
  language = lingo[lang]
  language.translate(str, params)


# Helpers for translation
I18n.helpers =
  translate: translate
  t: translate


module.exports = I18n

