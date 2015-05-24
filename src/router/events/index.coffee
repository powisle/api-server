Express   = require 'express'
config    = require 'config-object'
async     = require 'async'

router = new Express.Router


router.route '/'
  # Add new event
  .post (req, res, done) ->
    {
      date
      description
    } = req.body
    owner = 'Anonymous'

    # TODO: Validate date (2015-05-24)
    {redis} = req

    async.waterfall [
      (done) ->
        # Store a date
        redis.zadd 'dates', 0, date, done

      (result, done) ->
        # Increment and get events length as id
        redis.incr 'events:length', done

      (id, done) ->
        async.parallel [
          # Store event in date ordered set
          (done) -> redis.zadd "events:#{date}", 0, id, done
          # Score will reflect number of votes
          (done) -> redis.hmset "events:#{id}", {description, owner}, done
        ], (error) -> done error, id
    ], (error, id) ->
      if error then return done error

      res.locals = {status: 'ok', id}
      do done

  .get (req, res, done) ->
    req.redis
      .get 'visits'
      .then (visits) ->
        res.locals = { visits }
        do done
      .catch done

module.exports = router
