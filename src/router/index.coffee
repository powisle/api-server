Express   = require 'express'
config    = require 'config-object'

router = new Express.Router


router.route '/'
  .get (req, res, done) ->
    req.redis.incr 'visits'
    res.locals = config.clone root: 'package', keys: [
      'name'
      'version'
      'description'
    ]
    do done

router.route '/visits'
  .get (req, res, done) ->
    req.redis.get 'visits', (error, visits) ->
      if error then return done error
      res.locals = { visits }
      do done


# router.use '/events', require './events'

module.exports = router
