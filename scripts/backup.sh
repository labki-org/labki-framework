#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=${1:-./backups}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DB_DUMP="$BACKUP_DIR/db-$TIMESTAMP.sql.gz"
IMG_ARCHIVE="$BACKUP_DIR/images-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "[backup] Dumping database to $DB_DUMP"
mysqldump -h "${MW_DB_HOST:-db}" -u root -p"${MARIADB_ROOT_PASSWORD:-root_pass}" \
  "${MW_DB_NAME:-labki}" | gzip -9 > "$DB_DUMP"

echo "[backup] Archiving images to $IMG_ARCHIVE"
tar -C /var/www/html -czf "$IMG_ARCHIVE" images

echo "[backup] Backup complete"


