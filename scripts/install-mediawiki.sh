#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

php maintenance/install.php \
  --dbtype mysql \
  --dbname "${MW_DB_NAME:-labki}" \
  --dbserver "${MW_DB_HOST:-db}" \
  --dbuser "${MW_DB_USER:-labki}" \
  --dbpass "${MW_DB_PASSWORD:-labki_pass}" \
  --server "${MW_SERVER:-http://localhost:8080}" \
  --scriptpath "${MW_SCRIPT_PATH:-/w}" \
  --lang "${MW_SITE_LANG:-en}" \
  --pass "${MW_ADMIN_PASS:-changeme}" \
  "${MW_SITE_NAME:-Labki}" "${MW_ADMIN_USER:-admin}"

# Move generated LocalSettings.php to persistent config and append Labki defaults
if [ -f LocalSettings.php ]; then
  mkdir -p config
  mv LocalSettings.php config/LocalSettings.php
fi

# Append Labki configuration if not already present
if ! grep -q "Labki base configuration" config/LocalSettings.php; then
  cat >> config/LocalSettings.php <<'PHP'

/** Labki base configuration **/
$wgEnableUploads = true;
$wgMaxUploadSize = 1024 * 1024 * 100; // 100MB

// Friendly URLs
$wgScriptPath = getenv('MW_SCRIPT_PATH') ?: '/w';
$wgArticlePath = "/wiki/$1";

// Extensions
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Cite' );
wfLoadExtension( 'MsUpload' );
wfLoadExtension( 'VisualEditor' );

// VisualEditor
$wgDefaultUserOptions['visualeditor-enable'] = 1;
$wgVisualEditorEnableWikitext = true;

// Skin
wfLoadSkin( 'Chameleon' );
$wgDefaultSkin = 'chameleon';

// Semantic MediaWiki
wfLoadExtension( 'SemanticMediaWiki' );
enableSemantics( parse_url( getenv('MW_SERVER') ?: 'http://localhost:8080', PHP_URL_HOST ) ?: 'localhost' );

PHP
fi

echo "[install] Running maintenance/update.php to initialize database (incl. SMW)"
php maintenance/update.php --quick

echo "[install] LocalSettings.php configured and database updated"


