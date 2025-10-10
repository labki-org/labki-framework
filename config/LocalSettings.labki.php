<?php
// Labki opinionated settings layered on top of the installer-generated
// LocalSettings.php. This file is tracked in git and is INCLUDED at runtime.
// Do not put secrets here.

// Server and paths
if ( isset( $_SERVER['HTTP_HOST'] ) ) {
    $wgServer = getenv( 'MW_SERVER' ) ?: $wgServer;
}
$wgScriptPath = ""; // serve from document root (no /w)
$wgResourceBasePath = $wgScriptPath;
$wgArticlePath = "/wiki/$1";

// Uploads
$wgEnableUploads = true;
$wgMaxUploadSize = 1024 * 1024 * 100; // 100MB

wfLoadExtension( 'SemanticMediaWiki' );
enableSemantics( $wgServer );

// Default skin remains Vector until alternates are installed via Composer
// $wgDefaultSkin = 'chameleon';

// Core extensions that ship with MediaWiki
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Cite' );
wfLoadExtension( 'TemplateData' );
wfLoadExtension( 'ReplaceText' );
wfLoadExtension( 'Linter' );
wfLoadExtension( 'DiscussionTools' );
wfLoadExtension( 'Echo' );
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'WikiEditor' );
wfLoadExtension( 'Math' );
wfLoadExtension( 'OAuth' );

// Other extensions
wfLoadExtension( 'MsUpload' );

// Extensions for SWM
wfLoadExtension( 'SemanticResultFormats' );
wfLoadExtension( 'PageForms' );
wfLoadExtension( 'Maps' );
wfLoadExtension( 'SemanticExtraSpecialProperties' );
wfLoadExtension( 'SemanticCompoundQueries' );

// Skin
wfLoadSkin( 'Citizen' );
$wgDefaultSkin = 'citizen';

// Developer diagnostics (toggle with LABKI_DEBUG=1)
if ( getenv('LABKI_DEBUG') === '1' ) {
    $wgShowExceptionDetails = true;
    $wgDebugToolbar = true;
    $wgResourceLoaderDebug = true;
}

# Core upload settings
$wgEnableUploads = true;
$wgGroupPermissions['user']['upload'] = true;

# MsUpload recommended config
$wgMSU_useDragDrop = true;
$wgMSU_showAutoCat = true;
$wgMSU_checkAutoCat = true;
$wgMSU_confirmReplace = true;
$wgMSU_imgParams = '400px';
$wgMSU_uploadsize = '100mb';

# OAuth: grant administrative OAuth permissions to sysops and bureaucrats so
# the built-in admin account can register and manage OAuth consumers. The
# OAuth extension checks for specific permission keys; setting several likely
# permission names covers common variants used by different versions.
$wgGroupPermissions['sysop']['myauthoproposeconsumer'] = true;
$wgGroupPermissions['sysop']['oauthproposeconsumer'] = true;
$wgGroupPermissions['sysop']['oauthmanageconsumer'] = true;
$wgGroupPermissions['sysop']['oauthadmin'] = true;
$wgGroupPermissions['sysop']['oauth'] = true;

# Also allow bureaucrats the same capabilities where applicable
$wgGroupPermissions['bureaucrat']['myauthoproposeconsumer'] = true;
$wgGroupPermissions['bureaucrat']['oauthproposeconsumer'] = true;
$wgGroupPermissions['bureaucrat']['oauthmanageconsumer'] = true;
$wgGroupPermissions['bureaucrat']['oauthadmin'] = true;
$wgGroupPermissions['bureaucrat']['oauth'] = true;
