(function($) {

	$('#sass-yes').change(function() {
	    $('#compass').toggleClass('active');
	});

	$('#cpt-yes').change(function() {
	    $('#cpt-number-wrapper').toggleClass('active');
	});

	// Watch for change of CPT number and then create that many form fields
	$('#cpt-number').change(function() {
		var cpt_number = $('#cpt-number').val();

		while (cpt_number > 0) {
			var html_string = '<div class="question"><label>What is the CPT name?</label><input required class="name plain buffer" type="text" name="cpt_name_' + cpt_number.toString() + '" data-parsley-required="true"></div>';

			$('#cpt-name-wrapper').append(html_string);

			cpt_number = cpt_number - 1;
		}
	});
})(jQuery);