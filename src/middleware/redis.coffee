Redis = require 'ioredis'
Error2 = require 'error2'

redis = new Redis
  retryStrategy: (times) -> 200 if times < 5

redis.on 'end', -> throw new Error2 'Redis is down.'

module.exports = (req, res, done) ->
  req.redis = redis
  do done
