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
// Temporarily disable LabkiPackManager during initial DB upgrades: its bundled
// sqlite schema is incompatible with MariaDB and blocks update.php. Re-enable
// once a mysql-compatible schema is present.
// wfLoadExtension( 'LabkiPackManager' );
wfLoadExtension( 'PageSchemas' );

// Extensions for SWM
wfLoadExtension( 'SemanticResultFormats' );
wfLoadExtension( 'PageForms' );
wfLoadExtension( 'Maps' );
wfLoadExtension( 'SemanticExtraSpecialProperties' );
wfLoadExtension( 'SemanticCompoundQueries' );
wfLoadExtension( 'PageSchemas' );

// Skin
$bootstrapCfg = __DIR__ . '/../extensions/Bootstrap/extension.json';
if ( file_exists( $bootstrapCfg ) ) {
    wfLoadExtension( 'Bootstrap' );
} else {
    // If Bootstrap is missing, continue without it (instead use the Citizen skin).
}
wfLoadSkin( 'Citizen' );

$chameleonPath = __DIR__ . '/../skins/Chameleon/skin.json';
if ( file_exists( $chameleonPath ) ) {
    wfLoadSkin( 'Chameleon' );
    $wgDefaultSkin = 'Chameleon';
} else {
    // Use Citizen if Chameleon isn't available yet.
    $wgDefaultSkin = 'Citizen';
}

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
