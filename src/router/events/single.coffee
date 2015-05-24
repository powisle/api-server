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

router.route '/vote'
  .post (req, res, done) ->
    {
      redis
      user
      event
      date
    } = req
    # TODO:

    async.waterfall [
      (done) ->
        # Add user to events:id:voters set
        redis.sadd "events:#{event.id}:voters", user.email, done
      (result, done) ->
        # If user was added, then increase events:id.votes
        redis.hincrby "events:#{event.id}", "votes", result, done
      (votes, done) ->
        # Update score of an event on it's date
        redis.zadd "events:#{date}", votes, event.id, (error) ->
          done error, votes
    ], (error, votes) ->
      if error then return done error

      # Return new number of votes
      res.locals = {votes}
      do done

module.exports = router
