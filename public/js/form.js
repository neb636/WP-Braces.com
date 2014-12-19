var wp_braces = angular.module('wp-braces', []);

wp_braces.controller('PostTypesCtrl', function ($scope) {
	var self = this;

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