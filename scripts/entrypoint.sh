#!/usr/bin/env bash
set -euo pipefail

# Wait for DB using authenticated ping (avoids starting before creds work)
echo "[entrypoint] Waiting for database auth at ${MW_DB_HOST:-db}:3306 ..."
for i in {1..60}; do
  if MYSQL_PWD="${MW_DB_PASSWORD:-labki_pass}" mysql -h "${MW_DB_HOST:-db}" -u "${MW_DB_USER:-labki}" -e "SELECT 1" >/dev/null 2>&1; then
    echo "[entrypoint] Database is ready and credentials valid"
    break
  fi
  sleep 2
done

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

# First-run installation
if [ ! -f config/LocalSettings.php ]; then
  echo "[entrypoint] No LocalSettings.php found; running installer"
  /install-mediawiki.sh
else
  # If core tables are missing (new DB with existing LocalSettings.php), re-run installer
  if ! MYSQL_PWD="${MW_DB_PASSWORD:-labki_pass}" mysql -h "${MW_DB_HOST:-db}" -u "${MW_DB_USER:-labki}" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MW_DB_NAME:-labki}' AND table_name='page';" | grep -q '^1$'; then
    echo "[entrypoint] Fresh database detected with existing config; re-running installer to create core tables"
    mv -f config/LocalSettings.php config/LocalSettings.php.bak || true
    /install-mediawiki.sh
  fi
fi

# Ensure MediaWiki sees LocalSettings.php in document root
if [ -f config/LocalSettings.php ]; then
  echo "[entrypoint] Normalizing DB credentials in config/LocalSettings.php"
  sed -i "s/^\$wgDBserver = \".*\";/\$wgDBserver = \"${MW_DB_HOST:-db}\";/" config/LocalSettings.php || true
  sed -i "s/^\$wgDBname = \".*\";/\$wgDBname = \"${MW_DB_NAME:-labki}\";/" config/LocalSettings.php || true
  sed -i "s/^\$wgDBuser = \".*\";/\$wgDBuser = \"${MW_DB_USER:-labki}\";/" config/LocalSettings.php || true
  sed -i "s/^\$wgDBpassword = \".*\";/\$wgDBpassword = \"${MW_DB_PASSWORD:-labki_pass}\";/" config/LocalSettings.php || true
  echo "[entrypoint] Syncing config/LocalSettings.php to document root"
  cp -f config/LocalSettings.php LocalSettings.php
fi

popd >/dev/null

exec "$@"


