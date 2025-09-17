#!/usr/bin/env bash
set -euo pipefail

# Example helper: create database and user if needed (usually handled by envs)
mysql -h "${MW_DB_HOST:-db}" -u root -p"${MARIADB_ROOT_PASSWORD:-root_pass}" <<SQL
CREATE DATABASE IF NOT EXISTS \
  \`$MW_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$MW_DB_USER'@'%' IDENTIFIED BY '$MW_DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MW_DB_NAME\`.* TO '$MW_DB_USER'@'%';
FLUSH PRIVILEGES;
SQL

echo "[init-db] Database ensured"


