#!/usr/bin/env bash
set -euo pipefail

# Job runner wrapper that processes multiple LabkiPackManager job types
# MediaWiki's runJobs.php only accepts one --type at a time, so we loop through them

cd /var/www/html

# Ensure LocalSettings.php exists (entrypoint should have created it, but double-check)
if [ ! -f LocalSettings.php ] && [ -f config/LocalSettings.php ]; then
  cp -f config/LocalSettings.php LocalSettings.php
  chmod 644 LocalSettings.php || true
fi

# Job types to process
JOB_TYPES=("labkiRepoAdd" "labkiRepoSync" "labkiRepoRemove" "labkiPackApply")

echo "[jobrunner] Starting LabkiPackManager job runner..."
echo "[jobrunner] Will process job types: ${JOB_TYPES[*]}"

# Run job runner for each type in a continuous loop
# Use --maxjobs=1 per type to avoid blocking, then move to next type
while true; do
  for job_type in "${JOB_TYPES[@]}"; do
    echo "[jobrunner] Checking for jobs of type: $job_type"
    # Process one job of this type, or wait briefly if none available
    # Use --conf to explicitly point to config file
    php maintenance/runJobs.php --conf /var/www/html/config/LocalSettings.php --type="$job_type" --maxjobs=2 --maxtime=20 || true
  done
  
  # Small delay between cycles to avoid tight loops when no jobs available
  sleep 2
done

