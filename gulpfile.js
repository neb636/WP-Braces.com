// Plugins
var gulp = require('gulp'),
	 watch = require('gulp-watch'),
	 autoprefixer = require('gulp-autoprefixer'),
	 concat = require('gulp-concat'),
	 uglify = require('gulp-uglify'),
	 uncss = require('gulp-uncss');

// Order in which js files should be processed
var footer_js_order = [
	'public/js/jquery.js',
	'public/js/plugins.js',
	'public/js/beetle.js',
	'public/js/main.js',
	'public/js/validate.js'
];

// Styles
gulp.task('styles', function() {
	gulp.src('public/css/*.css')
		.pipe(concat('styles.css'))
		//.pipe(uglify())
		.pipe(autoprefixer('last 1 version', '> 1%', 'ie 9', 'ie 8', 'ie 7'))
		.pipe(gulp.dest('public/css/compiled'));
});

// Footer Scripts
gulp.task('footer_scripts', function() {
	gulp.src(footer_js_order)
		.pipe(concat('footer.js'))
		.pipe(uglify())
		.pipe(gulp.dest('public/js/compiled'));
});

gulp.task('watch', function() {
	// Watch the sass files
	gulp.watch('public/css/*.css', ['styles']);
	gulp.watch('public/js/*.js', ['footer_scripts']);
});

// Make all tasks run and then watch for the rest
gulp.task('default', ['styles', 'footer_scripts', 'watch']);
