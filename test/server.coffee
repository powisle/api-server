{ expect }  = require 'chai'
{ fork }    = require 'child_process'
request     = require 'request'
path        = require 'path'

app         = require '..'

module.exports = ->

  it 'is a module', ->
    expect app
      .to.exist

  it 'exposes an Express app', ->
    expect app
      .to.be.a 'function'
      .and.to.have.property 'listen'
      .which.is.a 'function'

  it.skip 'starts to listen when invoked without parrent module (forked)', (done) ->
    @timeout 5000
    server = fork path.resolve __dirname, '..'
    server.on 'message', (message) ->
      # A server sends a message when it's ready and listening
      if message.event is 'listening'
        request
          json: yes
          url : "http://localhost:#{message.port}/"
          (error, response, body) ->
            expect response
              .to.be.an 'object'
              .with.property 'statusCode', 200
            do server.kill
            do done
