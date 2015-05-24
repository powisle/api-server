Express   = require 'express'
config    = require 'config-object'
async     = require 'async'
Error2    = require 'error2'

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

router.param 'date', (req, res, done, date) ->
  {redis} = req

  async.waterfall [
    (done) -> redis.zrange "events:#{date}", 0, -1, done
    (events, done) ->
      req.date    = date
      async.map events,
        (id, done) ->
          redis.hgetall "events:#{id}", (error, event) ->
            if error then return done error
            event.id = id
            done error, event
        done
  ], (error, events) ->
    if error then return done error
    req.events = events

    do done

router.param 'event', (req, res, done, id) ->
  req.event = req.events
    .filter (event) -> event.id is id
    .pop()

  if not req.event then return done new Error2
    status  : 404
    name    : 'NotFound'
    message : 'Event not found'

  do done

router.route '/:date'
  .get (req, res, done) ->
    res.locals = req.events
    do done

router.route '/:date/:event'
  .get (req, res, done) ->
    res.locals = req.event
    do done

module.exports = router
