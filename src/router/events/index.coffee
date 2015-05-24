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
    {redis} = req

    redis.zrange 'dates', 0, -1, (error, dates) ->
      if error then return done error
      res.locals = dates.map (date) -> id: date
      do done

router.route '/:date'
  .get (req, res, done) ->
    {redis} = req
    {date} = req.params

    redis.zrange "events:#{date}", 0, -1, (error, events) ->
      if error then return done error
      res.locals = events.map (event) -> id: event
      do done

router.route '/:date/:event'
  .get (req, res, done) ->
    {redis} = req
    {
      date
      event
    } = req.params

    # TODO: Check if event matches date
    # TODO: Get votes
    redis.hgetall "events:#{event}", (error, event) ->
      if error then return done error
      res.locals = event
      do done

module.exports = router
