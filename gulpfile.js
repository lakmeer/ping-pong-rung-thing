
// Require

var gulp       = require('gulp'),
    gutil      = require('gulp-util'),
    browserify = require('browserify'),
    connect    = require('gulp-connect'),
    sass       = require('gulp-sass'),
    prefix     = require('gulp-autoprefixer'),
    source     = require('vinyl-source-stream');


// Helpers

function reload (files) {
  gulp.src(files.path).pipe(connect.reload());
}

function prettyLog (label, text) {
  gutil.log( gutil.colors.bold("  " + label + " | ") + text );
}

function errorReporter (err){
  gutil.log( gutil.colors.red("Error: ") + gutil.colors.yellow(err.plugin) );
  if (err.message)    { prettyLog("message", err.message); }
  if (err.fileName)   { prettyLog("in file", err.fileName); }
  if (err.lineNumber) { prettyLog("on line", err.lineNumber); }
  return this.emit('end');
};


// Preconfigure bundler

var bundler = browserify({
  debug: true,
  cache: {},
  packageCache: {},
  entries: [ './src/index.ls' ],
  extensions: '.ls'
});


// Tasks

gulp.task('server', function () {
  connect.server({
    root: 'public',
    livereload: true
  });
});

gulp.task('browserify', function () {
  return bundler
    .bundle()
    .on('error', errorReporter)
    .pipe(source('app.js'))
    .pipe(gulp.dest('public'))
});

gulp.task('styles', function () {
  gulp.src('styles/index.scss')
    .pipe(sass().on('error', errorReporter))
    .pipe(prefix())
    .pipe(gulp.dest('public'))
});


// Register

gulp.task('default', [ 'server', 'styles', 'browserify' ], function () {
  gulp.watch(['styles/**/*.scss'], [ 'styles' ]);
  gulp.watch(['src/**/*.ls'], [ 'browserify' ]);
  gulp.watch(['public/**/*']).on('change', reload);
});

