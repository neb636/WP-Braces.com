<?php
/**
 * Custom {%= post_type_name_capitalize %} Post Type
 *
 * @package WordPress
 * @subpackage {%= title_capitalize %}
 * @author {%= author %}
 * @link {%= author_uri %}
 *
 */

class {%= prefix_capitalize %}_Custom_{%= post_type_name_capitalize %} {

	/**
	 * Constants
	 */
	const POST_TYPE_SLUG             = '{%= post_type_name %}';
	const POST_TYPE_NAME             = '{%= post_type_name_capitalize %}';
	const POST_TYPE_SINGULAR         = '{%= post_type_name_capitalize %}s';
	const POST_TYPE_CAP              = 'post';

	// Define and register singleton
	private static $instance = false;
	public static function instance() {
		if ( !self::$instance ) {
			self::$instance = new self;
		}
		return self::$instance;
	}

	/**
	 * Clone
	 *
	 * @since 1.0.0
	 */
	private function __clone() { }

	/**
	 * Constructor
	 *
	 * @since 1.0.0
	 */
	private function __construct() {
		add_action( 'init', array( $this, 'action_init_register_post_type' ) );
	}

	/**
	 * Register {%= post_type_name %} post type
	 * @return void
	 */
	function action_init_register_post_type() {
		register_post_type( self::POST_TYPE_SLUG, array(
			'labels' => array(
				'name'          => __( self::POST_TYPE_NAME ),
				'singular_name' => __( self::POST_TYPE_SINGULAR ),
				'add_new_item'  => __( 'Add New ' . self::POST_TYPE_SINGULAR ),
				'edit_item'     => __( 'Edit ' . self::POST_TYPE_SINGULAR ),
				'new_item'      => __( 'New ' . self::POST_TYPE_SINGULAR ),
				'all_items'     => __( self::POST_TYPE_NAME ),
				'view_item'     => __( 'View ' . self::POST_TYPE_SINGULAR ),
				'search_items'  => __( 'Search' . self::POST_TYPE_NAME ),
			),
			'public'          => true,
			'capability_type' => self::POST_TYPE_CAP,
			'has_archive'     => true,
			'show_ui'         => true,
			'show_in_menu'    => true,
			'hierarchical'    => false,
			'supports'        => array( 'title' ),
			'menu_position'   => 16,
		) );
	}
}

{%= prefix_capitalize %}_Custom_{%= post_type_name_capitalize %}::instance();