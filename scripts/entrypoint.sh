#!/usr/bin/env bash
set -euo pipefail

# Wait for DB using authenticated ping (avoids starting before creds work)
echo "[entrypoint] Waiting for database auth at ${MW_DB_HOST:-db}:3306 ..."
for i in {1..60}; do
  if MYSQL_PWD="${MW_DB_PASSWORD:-labki_pass}" mysql --ssl=0 --protocol=TCP -h "${MW_DB_HOST:-db}" -u "${MW_DB_USER:-labki}" -e "SELECT 1" >/dev/null 2>&1; then
    echo "[entrypoint] Database is ready and credentials valid"
    break
  fi
  sleep 2
done

exec "$@"


