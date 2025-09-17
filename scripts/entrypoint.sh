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
fi

popd >/dev/null

exec "$@"


