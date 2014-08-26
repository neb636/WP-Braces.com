// Plugins
var gulp = require('gulp'),
	 watch = require('gulp-watch'),
	 autoprefixer = require('gulp-autoprefixer'),
	 concat = require('gulp-concat'),
	 sass = require('gulp-ruby-sass'),
	 uglify = require('gulp-uglify'),
	 uncss = require('gulp-uncss'),
	 plumber = require('gulp-plumber'),
	 gutil = require('gulp-util'),
	 mincss = require('gulp-minify-css');

var js_footer = [
		'public/js/plugins.js',
		'public/js/beetle.js',
		'public/js/parsley.js',
		'public/js/form.js'
	]

var erb_files = [
		'views/header.erb',
		'views/error.erb',
		'views/form_validate.erb',
		'views/footer.erb',
		'views/form.erb',
		'views/index.erb'
	]

var ignore_css = [
		/.fixed-header/,
		/.active/,
		/.sticky-footer/,
		'.skrollable',
		'.skrollable-after',
		'.js',
		'.flexbox',
		'.backgroundsize',
		'.borderradius',
		'.boxshadow',
		'.cssanimations',
		'.csstransforms',
		'.csstransforms3d',
		'.csstransitions',
		'.svg',
		'.skrollr',
		'.skrollr-desktop'
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
		.pipe(sass({style: 'compressed'}))
		.pipe(autoprefixer('last 1 version', '> 1%', 'ie 9', 'ie 8', 'ie 7'))
		.pipe(uncss({
         html: erb_files,
         ignore: ignore_css
      }))
      .pipe(mincss())
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
