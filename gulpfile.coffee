gulp        = require 'gulp'
mocha       = require 'gulp-mocha'
coffee      = require 'gulp-coffee'
sourcemaps  = require 'gulp-sourcemaps'
through     = require 'through2'
del         = require 'del'
{ fork }    = require 'child_process'

gulp.task 'clean', (done) ->
  del 'build/**/*', done

gulp.task 'coffee', ->
  development = process.env.NODE_ENV is 'development'

  gulp
    .src 'src/**/*.coffee'
    .pipe sourcemaps.init()
    .pipe coffee()
    # Only write source maps if env is development. Otherwise just pass thgrough.
    .pipe if development then sourcemaps.write 'sources/' else through.obj()
    .pipe gulp.dest 'build/'

gulp.task 'test', ->
  development = process.env.NODE_ENV is 'development'

  gulp
    .src 'test/*.coffee', read: no
    .pipe mocha
      reporter  : 'list'
      compilers : 'coffee:coffee-script'
    .once 'error', (error) ->
      console.error 'Tests failed'
      console.error error.stack
      if development
        return @emit 'end'
      else
        process.exit 1

gulp.task 'build', gulp.series [
  'clean'
  'coffee'
  'test'
]

server = null
gulp.task 'start', (done) ->
  server = fork __dirname
  do done

gulp.task 'stop', (done) ->
  if not server then return do done

  server.kill 'SIGINT'
  do done

gulp.task 'watch', (done) ->
  gulp.watch [
    'test/**/*'
    'package.json'
  ], gulp.series [
    'stop'
    'start'
    'test'
  ]

  gulp.watch [
    'src/**/*.coffee',
  ], gulp.series [
    'build'
    'stop'
    'start'
  ]

gulp.task 'develop', gulp.series [
  (done) ->
    process.env.NODE_ENV ?= 'development'
    do done
  'build'
  'start'
  'watch'
]
