#!/usr/bin/env bash
set -euo pipefail

# Wait for DB using bash TCP check (avoids netcat dependency)
echo "[entrypoint] Waiting for database at ${MW_DB_HOST:-db}:3306 ..."
for i in {1..60}; do
  if (echo > "/dev/tcp/${MW_DB_HOST:-db}/3306") >/dev/null 2>&1; then
    echo "[entrypoint] Database is ready"
    break
  fi
  sleep 2
done

pushd /var/www/html >/dev/null

# First-run installation
if [ ! -f config/LocalSettings.php ]; then
  echo "[entrypoint] No LocalSettings.php found; running installer"
  /install-mediawiki.sh
else
  # Ensure config matches current DB credentials; try a quick DB ping to avoid stale config crash
  if ! MYSQL_PWD="${MW_DB_PASSWORD:-labki_pass}" mysql -h "${MW_DB_HOST:-db}" -u "${MW_DB_USER:-labki}" -e "SELECT 1" >/dev/null 2>&1; then
    echo "[entrypoint] Database not reachable with current credentials; will retry on next start"
    exit 1
  fi
  # If core tables are missing (new DB with existing LocalSettings.php), initialize schema
  if ! MYSQL_PWD="${MW_DB_PASSWORD:-labki_pass}" mysql -h "${MW_DB_HOST:-db}" -u "${MW_DB_USER:-labki}" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MW_DB_NAME:-labki}' AND table_name='page';" | grep -q '^1$'; then
    echo "[entrypoint] MediaWiki core tables not found; running maintenance/update.php"
    php maintenance/update.php --quick
  fi
fi

# Ensure MediaWiki sees LocalSettings.php in document root
if [ -f config/LocalSettings.php ]; then
  echo "[entrypoint] Syncing config/LocalSettings.php to document root"
  cp -f config/LocalSettings.php LocalSettings.php
fi

popd >/dev/null

exec "$@"


