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

// Default skin remains Vector until alternates are installed via Composer
// $wgDefaultSkin = 'chameleon';

// Core extensions that ship with MediaWiki
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Cite' );

wfLoadExtension( 'VisualEditor' );

// Defer third-party extensions/skins until installed via Composer
// wfLoadExtension( 'MsUpload' );
// wfLoadExtension( 'VisualEditor' );
// wfLoadExtension( 'SemanticMediaWiki' );
// enableSemantics( parse_url( getenv('MW_SERVER') ?: 'http://localhost:8080', PHP_URL_HOST ) ?: 'localhost' );
// wfLoadSkin( 'Chameleon' );

// Developer diagnostics (toggle with LABKI_DEBUG=1)
if ( getenv('LABKI_DEBUG') === '1' ) {
    $wgShowExceptionDetails = true;
    $wgDebugToolbar = true;
    $wgResourceLoaderDebug = true;
}


