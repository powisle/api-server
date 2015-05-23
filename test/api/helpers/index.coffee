# Some helper functions to write less code in each test case

request     = require 'request'

# TODO: Make it an NPM package
# TODO: Write tests for this

module.exports =
  initialize: (options = {}) ->
    {
      context
      root
      baseUrl
    } = options

    # Default values
    root      ?= context.test.parent
    baseUrl   ?= "http://localhost:8000/"

    prototype = context.constructor.prototype

    # Methods:

    # Autodetect API endpoint from test case context
    prototype.endpoint = ->
      unit    = @test.parent  # Start with parent suit.
      method  = unit.title

      if method not in [
        'GET'
        'HEAD'
        'POST'
        'PUT'
        'DELETE'
        'TRACE'
        'OPTIONS'
        'CONNECT'
        'PATCH'
      ] then throw new Error "Last suit has to indicate request method, e.g. GET or POST. #{method} given instead."

      path    = ''
      while unit = unit.parent
        break if unit is root

        # Suit title can span multiple segments
        # eg. '/streets/1234 (Marszałkowska)/houses/20/restaurants'

        segments = '/' + unit.title
          .split '/'
          .map (segment) ->
            segment
              .replace /\(.+\)/g, ''  # Everything inside parentheses is comment
              .replace /\s+/g, ''     # Drop all whitespace
          .filter (segment) ->
            segment isnt ''           # Drop empty segments
          .join '/'

        path = segments + path

      return {path, method}

    # Call API endpoint
    prototype.call = (options = {}, callback) ->
      # Make options optional
      if typeof options is 'function' and callback is undefined
        [options, callback] = [{}, options]
      # Or let it be just URL string
      else if typeof options is 'string'
        options = url: options

      # Set default values
      options.baseUrl   ?= baseUrl # From options to initialize, see above
      options.json      ?= yes

      # If either method or path is missing - autodetect it using endpoint
      unless options.method? and options.path?
        endpoint = do @endpoint
        options.method  ?= endpoint.method
        options.url     ?= endpoint.path

      # Finally do the request
      request options, callback
