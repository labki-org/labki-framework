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
  --scriptpath "${MW_SCRIPT_PATH:-}" \
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

// Friendly URLs (serve from document root; no /w prefix)
$wgScriptPath = "";
$wgArticlePath = "/wiki/$1";
$wgResourceBasePath = $wgScriptPath;

// Extensions
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Cite' );

// VisualEditor deferred for composer-only minimal bring-up

// Skin
wfLoadSkin( 'Chameleon' );
$wgDefaultSkin = 'chameleon';

// (Semantic MediaWiki deferred for later composer setup)

PHP
fi

echo "[install] Running maintenance/update.php to initialize database"
php maintenance/update.php --quick

echo "[install] LocalSettings.php configured and database updated"


