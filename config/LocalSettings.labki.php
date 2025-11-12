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

// Default skin — we'll pick Chameleon when it's present, otherwise fall back
// to the Citizen skin. 
// (Actual $wgDefaultSkin value is set below after probing files.)

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
    // Load Bootstrap extension if present (Chameleon depends on it).
    wfLoadExtension( 'Bootstrap' );
}

$chameleonPath = __DIR__ . '/../skins/Chameleon/skin.json';
// Prefer Chameleon when it's available and Bootstrap is installed. Fall back
// to Citizen otherwise to avoid fatal runtime errors when files
// haven't been installed inside the container yet.
if ( file_exists( $chameleonPath ) && file_exists( $bootstrapCfg ) ) {
    wfLoadSkin( 'Chameleon' );
    $wgDefaultSkin = 'Chameleon';
} else {
    // Keep the lightweight Citizen skin as a safe fallback.
    wfLoadSkin( 'Citizen' );
    $wgDefaultSkin = 'Citizen';
}
// Developer diagnostics (toggle with LABKI_DEBUG=1)
if ( getenv('LABKI_DEBUG') === '1' ) {
    $wgShowExceptionDetails = true;
    $wgDebugToolbar = true;
    $wgResourceLoaderDebug = true;
    $wgLogExceptionBacktrace = true;
}

// Chameleon skin customization

// Available layouts are registered below in $egChameleonAvailableLayoutFiles.
$egChameleonLayoutFile = __DIR__ . '/../skins/Chameleon/layouts/navhead.xml';

// Make the bundled layouts available to the uselayout URL parameter.
$egChameleonAvailableLayoutFiles = [
    'standard'   => __DIR__ . '/../skins/Chameleon/layouts/standard.xml',
    'navhead'    => __DIR__ . '/../skins/Chameleon/layouts/navhead.xml',
    'fixedhead'  => __DIR__ . '/../skins/Chameleon/layouts/fixedhead.xml',
    'stickyhead' => __DIR__ . '/../skins/Chameleon/layouts/stickyhead.xml',
    'clean'      => __DIR__ . '/../skins/Chameleon/layouts/clean.xml',
];

// Theme file: set to '' to use Bootstrap defaults, or point to a local SCSS
// file to load a custom theme (absolute path recommended using __DIR__).
// Example: $egChameleonThemeFile = __DIR__ . '/themes/united.scss';
$egChameleonThemeFile = '';

// Import additional SCSS files (path => position). Positions are optional.
$egChameleonExternalStyleModules = [
    // Local themes and variable overrides (paths are relative to config/)
    // Load Google Fonts first so font-face rules are available to the page.
    __DIR__ . '/themes/_google_fonts.scss' => 'beforeMain',
    __DIR__ . '/themes/_local_variables.scss' => 'afterVariables',
    // __DIR__ . '/../themes/custom_overrides.scss' => 'afterMain',
];

// Override SCSS variables without editing skin files. Omit the leading $.
// Example: change collapse breakpoint used by Chameleon.
$egChameleonExternalStyleVariables = [
    'cmln-collapse-point' => '960px',
    // 'body-bg' => '#ffffff',
];

// Trigger SCSS cache rebuild when a file changes. The Bootstrap manager can
// watch a file to force a rebuild when it changes; pointing it at a theme
// or an SCSS variables file is handy during development.
if ( class_exists( '\\Bootstrap\\BootstrapManager' ) ) {
    // Watch the default theme file (if present) so touching it rebuilds styles.
    $trigger = __DIR__ . '/../skins/Chameleon/resources/styles/themes/_light.scss';
    if ( file_exists( $trigger ) ) {
        \Bootstrap\BootstrapManager::getInstance()->addCacheTriggerFile( $trigger );
    }
    // Also watch our local variables file so edits trigger a rebuild during dev.
    $localVarTrigger = __DIR__ . '/themes/_local_variables.scss';
    if ( file_exists( $localVarTrigger ) ) {
        \Bootstrap\BootstrapManager::getInstance()->addCacheTriggerFile( $localVarTrigger );
    }
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
