Braces
===

Braces is a WordPress starter theme with a command line build tool called builder. Braces is starter theme meant for hacking and is a fork of Underscores.
Braces does not use the alternate syntax for control structures that is common in the WordPress community.


* Licensed under GPLv2 or later.

Getting Started
---------------

For now you type ruby gadget.rb in the command line to access the build tool

Good luck!

# (S)CSS Comment Structure(s) Examples #
----------------------------

## File Header Comments ##
/*
 * @file Header Styles
 * ------------------------------------------------------------------------------- */

## Full Comments ##
/* Header
 * --------------------------------------------------------------------------------- */

## Inline Comments ##
/* --- Header - Social --------------------------------------------------------------- */

## Section Comments ##
/* Social Lists */

# Notes #
----------------------
Lets always update to the latest version on Modernizr @link http://modernizr.com/download/

# Some Kickass Plugins #
----------------------
http://dotdotdot.frebsite.nl/
http://wordpress.org/plugins/custom-metadata/
http://wordpress.org/plugins/option-tree/
http://soliloquywp.com
http://wordpress.org/plugins/post-meta-inspector/
https://thinkoomph.svn.beanstalkapp.com/oomph-plugins/

# Changelog #
-------------
2014-03-19 ( https://thinkoomph.jira.com/browse/OBT-30 )
- update no-results.php to content-none.php & refs to no-results.php
- remove title attribute from content single
- add recommend content width https://codex.wordpress.org/Content_Width
- add minimal-ui viewport meta tag http://zerosixthree.se/minimal-ui-meta-tag/
- various css updates
- various function documentation additions
- remove comment function in favor of wp_list_comment($args) https://github.com/Automattic/_s/commit/cb52da6f23cee416fdb913542ed80404b1821718
- update the post and page nav functions https://github.com/Automattic/_s/commit/3f4effb5f0dfe62fb7c2704938cebf3605d681f6
- fix error on search.php with closing braces
- add HTML5 theme support http://codex.wordpress.org/Function_Reference/add_theme_support?codekitCB=416939597.813249#HTML5
