#!/usr/bin/env bash
set -euo pipefail

# General job runner that processes all MediaWiki jobs
# Uses --wait to continuously process jobs as they're queued

cd /var/www/html

# Ensure LocalSettings.php exists (entrypoint should have created it, but double-check)
if [ ! -f LocalSettings.php ] && [ -f config/LocalSettings.php ]; then
  cp -f config/LocalSettings.php LocalSettings.php
  chmod 644 LocalSettings.php || true
fi

echo "[jobrunner] Starting MediaWiki job runner..."
echo "[jobrunner] Will process all job types continuously"

# Run job runner continuously with --wait flag
# --wait: Wait for new jobs instead of exiting when queue is empty
# --maxjobs: Process up to 20 jobs per run before checking for new jobs
# --maxtime: Maximum 5 minutes per run before checking for new jobs
php maintenance/runJobs.php \
  --conf /var/www/html/config/LocalSettings.php \
  --wait \
  --maxjobs=20 \
  --maxtime=300 \
  || true

