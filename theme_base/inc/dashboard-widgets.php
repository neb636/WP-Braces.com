<?php
/**
 *
 * @package WordPress
 * @subpackage oomph_theme
 * @author Oomph, Inc.
 * @link http://www.oomphinc.com
 */

class Oomph_Dashboard_Widget {

	/**
	 * Register the Oomph branded Dashboard Widget
	 */
	public static function init() {
		global $wp_meta_boxes;
		add_meta_box( 'oomph_dashboard_widget', 'Connect with Oomph', 'display_dashboard_widget', 'dashboard', 'normal', 'high' );

		/**
		 * Display the Oomph branded Dashboard Widget
		 */
			function display_dashboard_widget() { ?>
			<p>
				Site implementation by <a target="_blank" href="http://www.oomphinc.com">Oomph, Inc.</a><br/>
				For support requests email us at <a href="mailto:info@oomphinc.com">info ( at ) thinkoomph.com</a>
			</p>

			<h4>Follow Us on Social Media</h4>
			<ul>
				<li><a target="_blank" href="http://www.facebook.com/oomphinc">Facebook</a></li>
				<li><a target="_blank" href="http://www.linkedin.com/company/oomph-inc.">LinkedIn</a></li>
				<li><a target="_blank" href="http://www.twitter.com/oomphinc">Twitter</a></li>
				<li><a target="_blank" href="https://plus.google.com/105244513520574503277/about">Google +</a></li>
				<li><a target="_blank" href="http://www.flickr.com/groups/2195816@N20/pool">Flickr</a></li>
				<li><a target="_blank" href="http://instagram.com/oomphinc">Instagram</a></li>
			</ul>

			<h4>Recent News</h4>
			<?php
				wp_widget_rss_output(array(
					'url' => 'http://www.thinkoomph.com/feed',
					'title' => 'Oomph Thinking',
					'items' => 3,
					'show_summary' => 1,
					'show_author' => 0,
					'show_date' => 1
				));

			}

	}

}

add_action( 'wp_dashboard_setup', array( 'Oomph_Dashboard_Widget', 'init' ) );