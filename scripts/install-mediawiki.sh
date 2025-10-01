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

# Always include Labki layered settings so our config is authoritative
if ! grep -q "config/LocalSettings.labki.php" config/LocalSettings.php; then
  {
    echo "";
    echo "// Include Labki layered settings (managed in git) from either context";
    echo "\$__LS_LABKI = __DIR__ . '/config/LocalSettings.labki.php';";
    echo "if ( !file_exists(\$__LS_LABKI) ) {";
    echo "    // If this file itself lives in /var/www/html/config, use the sibling file";
    echo "    \$__LS_LABKI = __DIR__ . '/LocalSettings.labki.php';";
    echo "}";
    echo "require_once \$__LS_LABKI;";
    echo "unset(\$__LS_LABKI);";
  } >> config/LocalSettings.php
fi

echo "[install] Running maintenance/update.php (first pass)"
php maintenance/update.php --quick --conf config/LocalSettings.php || true

php extensions/SemanticMediaWiki/maintenance/setupStore.php --skip-optimize --conf config/LocalSettings.php

echo "[install] Running maintenance/update.php (second pass)"
php maintenance/update.php --quick --conf config/LocalSettings.php || true

echo "[install] LocalSettings.php configured and database updated"

if [ -d extensions/SemanticMediaWiki ]; then
  echo "[install] Running SMW setupStore.php to finalize schema"
  php extensions/SemanticMediaWiki/maintenance/setupStore.php --skip-optimize --conf config/LocalSettings.php
fi

php maintenance/run.php rebuildLocalisationCache