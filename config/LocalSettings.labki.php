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

// Other extensions
wfLoadExtension( 'MsUpload' );
wfLoadExtension( 'Mermaid' );
wfLoadExtension( 'LabkiPackManager' );
wfLoadExtension( 'PageSchemas' );

// Extensions for SWM
wfLoadExtension( 'SemanticResultFormats' );
wfLoadExtension( 'PageForms' );
wfLoadExtension( 'Maps' );
wfLoadExtension( 'SemanticExtraSpecialProperties' );
wfLoadExtension( 'SemanticCompoundQueries' );
wfLoadExtension( 'PageSchemas' );

// Skin
wfLoadSkin( 'Citizen' );
$wgDefaultSkin = 'Citizen';

// Developer diagnostics (toggle with LABKI_DEBUG=1)
if ( getenv('LABKI_DEBUG') === '1' ) {
    $wgShowExceptionDetails = true;
    $wgDebugToolbar = true;
    $wgResourceLoaderDebug = true;
    $wgLogExceptionBacktrace = true;
}

$wgShowExceptionDetails = true;
$wgShowDBErrorBacktrace = true;
$wgDevelopmentWarnings = true;
error_reporting( -1 );
ini_set( 'display_errors', 1 );


# Core upload settings
$wgEnableUploads = true;
$wgGroupPermissions['user']['upload'] = true;

# LabkiPackManager settings
$wgGroupPermissions['sysop']['labkipackmanager-manage'] = true;

# MsUpload recommended config
$wgMSU_useDragDrop = true;
$wgMSU_showAutoCat = true;
$wgMSU_checkAutoCat = true;
$wgMSU_confirmReplace = true;
$wgMSU_imgParams = '400px';
$wgMSU_uploadsize = '100mb';
