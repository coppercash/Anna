var gulp = require("gulp");
var gutil = require('gulp-util');
var browserify = require("browserify");
var source = require('vinyl-source-stream');
var tsify = require("tsify");

gulp.task("bundle", function () {
    return browserify({
        basedir: '.',
        debug: true,
        entries: ['src/main.ts'],
        cache: {},
        packageCache: {}
    })
    .plugin(tsify)
    .bundle()
    .on('error', gutil.log)
    .pipe(source('anna.js'))
    .pipe(gulp.dest("dist"));
});

gulp.task("watch", function() {
    gulp.watch('src/*.ts', ['bundle']);
});

gulp.task("default", ["watch", "bundle"]);

