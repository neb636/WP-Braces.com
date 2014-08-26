// Plugins
var gulp = require('gulp'),
	 watch = require('gulp-watch'),
	 autoprefixer = require('gulp-autoprefixer'),
	 concat = require('gulp-concat'),
	 sass = require('gulp-ruby-sass'),
	 uglify = require('gulp-uglify'),
	 uncss = require('gulp-uncss');
	 plumber = require('gulp-plumber'),
	 gutil = require('gulp-util');

var js_footer = [
		'public/js/plugins.js',
		'public/js/beetle.js',
		'public/js/parsley.js',
		'public/js/form.js'
		]


// Outputs an error through plumber plugin
var onError = function (err) {
  gutil.beep();
  console.log(err);
};

// Styles
gulp.task('styles', function() {
	gulp.src('public/sass/styles.scss')
		.pipe(plumber({ errorHandler: onError }))
		.pipe(sass({style: 'compressed', sourcemap: true}))
		.pipe(autoprefixer('last 1 version', '> 1%', 'ie 9', 'ie 8', 'ie 7'))
		.pipe(gulp.dest('public/css/'));
});

// Footer Scripts
gulp.task('footer_scripts', function() {
	gulp.src(js_footer)
		.pipe(plumber({ errorHandler: onError }))
		.pipe(concat('footer.js'))
		.pipe(uglify())
		.pipe(gulp.dest('public/js/compiled'));
});

gulp.task('watch', function() {
	gulp.watch('public/js/*.js', ['footer_scripts']);
	gulp.watch('public/sass/*.scss', ['styles']);
});

// Make all tasks run and then watch for the rest
gulp.task('default', ['styles', 'footer_scripts', 'watch']);
