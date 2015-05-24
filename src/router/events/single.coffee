Express   = require 'express'
config    = require 'config-object'
async     = require 'async'
Error2    = require 'error2'

# Single event router

router = new Express.Router

router.route '/'
  .get (req, res, done) ->
    res.locals = req.event
    do done

module.exports = router
