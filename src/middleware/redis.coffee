Redis = require 'ioredis'
redis = new Redis

module.exports = (req, res, done) ->
  req.redis = redis
  do done
