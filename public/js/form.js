var wp_braces = angular.module('wp-braces', []);

wp_braces.controller('PostTypesCtrl', function () {
	var self = this;

	// Asks user how many post types needed. If amount is more than 15 display an
	// error otherwise create new array with number of cpts needed and do ng-repeat
	// to simulate doing something like _.times in Angular.
	self.update_amount = function() {
		self.amount = parseInt(self.amount);

		if (self.amount > 15) {
			self.parsley_error = 'parsley-error';
		}
		else {
			self.parsley_error = '';
			self.number = new Array(self.amount);
		}
	};
});
