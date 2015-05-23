{ expect }  = require 'chai'
helpers     = require './helpers'

app         = require '../..'

module.exports = ->
  # Upstream API server is sooo sloooo
  @timeout 10000

  # Before each test start and assign a new instance here
  server  = null

  before ->
    helpers.initialize
      context: @
      baseUrl: "http://localhost:8010/"

  beforeEach (done) ->
    server = app.listen 8010, done

  afterEach (done) ->
    server.close done

  describe '/', ->
    describe 'GET', ->
      it "reports server name and version", (done) ->
        @call (error, response, body) ->
          if error then return done error

          expect response
            .to.be.an 'object'
            .and.to.have.property 'statusCode', 200

          expect body
            .to.be.an 'object'
            .with.property 'name', 'powisle-api-server'

          expect body
            .to.have.property 'version'
            .which.is.a 'string'
            .and.match /^[0-9]+\.[0-9]+\.[0-9]+$/

          do done
          
