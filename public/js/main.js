// jQuery(document).ready(function ($) {

// 	if $('#compass_yes').prop('checked') {
// 		console.log('dog');
// 	}

// });

$('#sass-yes').change(function() {
    $('#compass').toggleClass('active');
});

$('#cpt-yes').change(function() {
    $('#compass').toggleClass('active');
});
