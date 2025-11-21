#!/usr/bin/env bash
set -euo pipefail

pushd /var/www/html >/dev/null

# Optional reset controls (for convenience during development)
if [ "${LABKI_RESET:-0}" = "1" ]; then
  echo "[entrypoint] LABKI_RESET=1: resetting LocalSettings and optional DB"
  rm -f LocalSettings.php config/LocalSettings.php || true
  if [ "${LABKI_RESET_DB:-0}" = "1" ] && [ -n "${MARIADB_ROOT_PASSWORD:-}" ]; then
    echo "[entrypoint] LABKI_RESET_DB=1: dropping and recreating database ${MW_DB_NAME:-labki}"
    MYSQL_PWD="${MARIADB_ROOT_PASSWORD}" mysql -h "${MW_DB_HOST:-db}" -u root -e "DROP DATABASE IF EXISTS \`${MW_DB_NAME:-labki}\`; CREATE DATABASE \`${MW_DB_NAME:-labki}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" || true
  fi
fi

# don't install if localsettings present (as a symlink to mounted config directory)
if [ -e ./config/LocalSettings.php ]; then
  echo "config/LocalSettings.php present, not running first-install script"
  /scripts/update-config.sh
  popd >/dev/null
  exit 0
fi

# Create and mutate LocalSettings.php
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

# Copy image LocalSettings to config directory, which will become canonical in future startups.
mkdir -p config
cp -f  ./LocalSettings.php config/LocalSettings.php

# Extension-specific scripts
bash /scripts/init-smw.sh

chown www-data LocalSettings.php

popd >/dev/null