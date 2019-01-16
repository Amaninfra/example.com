<?php
/**
 * Load modules
 */
// require_once(dirname(__FILE__) . '/app/post-types/testimonial.php');

/**
 * Place ACF JSON in field-groups directory
 */
add_filter('acf/settings/save_json', function($path) {
    return dirname(__FILE__) . '/app/field-groups';
});
add_filter('acf/settings/load_json', function($paths) {
    unset($paths[0]);
    $paths[] = dirname(__FILE__) . '/app/field-groups';
    return $paths;
});

/**
 * Force Gravity Forms JS to footer
 */
add_filter('gform_init_scripts_footer', '__return_true');

/**
 * Disable Stream front-end credit
 */
add_filter('wp_stream_frontend_indicator', '__return_false');

/**
 * Low priority for The SEO Framework metabox
 */
add_filter('the_seo_framework_metabox_priority', function() {
    return 'low';
});
