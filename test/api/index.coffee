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

    describe 'events/', ->
      describe 'POST', ->
        it 'requires a date and description'

        it 'stores a new unaccepted event'

        it 'requires user to be authenticated'

      describe 'GET', ->

        it 'gives a list of all dates with events'

      describe '2015-06-20 (date)/', ->
        describe 'GET', ->
          it 'gives a list of all accepted events'

          it 'for moderator gives a list of all events'

        describe '1 (event id)/', ->
          describe 'GET', ->
            it 'gives all the data of the event'

          describe 'DELETE', ->
            it 'removes the event'

            it 'can be done only by moderator'

          describe 'vote/', ->
            describe 'POST', ->
              it 'increases number of votes'

              it 'won\'t work twice for same event and user'

          describe 'accept/', ->
            describe 'POST', ->
              it 'makes the event accepted'

              it 'can be done by moderator only'

            describe 'DELETE', ->
              it 'makes the event not accepted'

              it 'can be done by moderator only'
