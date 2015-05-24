Express   = require 'express'
Error2    = require 'error2'
Logdown   = require 'logdown'
config    = require 'config-object'
cors      = require 'cors'
body      = require 'body-parser'

logger    = new Logdown prefix: 'api-server'

config.load '../defaults.cson' , required: yes
config.load '../package.json'  , required: yes, at: 'package'
config.load '../config.cson'

app = new Express

if process.env.NODE_ENV is 'development' then app.enable 'debug'

app.use require './middleware/redis'
app.use body.json extended: yes
app.use (req, res, done) ->
  # TODO: Real authentication and session
  req.user =
    name  : 'Anonymous User'
    email : 'user@example.com'
    role  : 'participant'
  do done
app.use do cors # TODO: Be more specific with CORS
app.use require './router'
app.use (req, res, done) ->
  # Serve middleware that send res.locals as a JSON string and does the logging.
  # Routes are expected to set res.locals instead of sending data themselves.

  # If no route matches path then pass 404 to error midddleware
  if not req.route then return done new Error2
    status  : 404
    name    : 'NotFoundError'
    message : "No such route: #{req.path}"
    path    : req.path

  logger.log "*#{req.method}\t#{req.path}* 200 OK" if app.enabled 'logs'
  res.json res.locals

app.use (error, req, res, done) ->
  error.status ?= 500

  # TODO: Use tj/log.js for logging and caiogondim/logdown for printing
  if app.enabled 'logs'
    logger.warn "*#{req.method}\t#{req.path}* #{error.status} #{error}"
    console.log error.stack if app.enabled 'debug'

  res
    .status error.status
    .json   error

if module.parent then module.exports = app
else
  app.enable 'logs' # Print logs to stdout / stderr only in standalone mode
  port = config.get 'api/port'
  app.listen port
  process.send? {port, event: 'listening'}
  logger.info "Server started on port `#{port}`"
