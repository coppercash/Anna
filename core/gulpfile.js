var gulp = require("gulp");
var gutil = require('gulp-util');
var browserify = require("browserify");
var source = require('vinyl-source-stream');
var tsify = require("tsify");

gulp.task("bundle", function () {
  return browserify({
    basedir: '.',
    entries: ['src/index.ts'],
    standalone: "Anna",
    debug: false,
    node: true,
  })
    .plugin(tsify)
    .bundle()
    .on('error', gutil.log)
    .pipe(source('index.js'))
    .pipe(gulp.dest("built/anna"));
});

gulp.task("watch", function() {
  gulp.watch('src/*.ts', ['bundle']);
});

gulp.task("default", ["bundle"]);

