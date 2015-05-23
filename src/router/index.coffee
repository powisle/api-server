Express   = require 'express'
config    = require 'config-object'

router = new Express.Router

router.route '/'
  .get (req, res, done) ->
    res.locals = config.clone root: 'package', keys: [
      'name'
      'version'
      'description'
    ]
    do done

# router.use '/events', require './events'

module.exports = router
