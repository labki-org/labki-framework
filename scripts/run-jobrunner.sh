#!/usr/bin/env bash
set -euo pipefail

# Job runner wrapper that processes multiple LabkiPackManager job types
# MediaWiki's runJobs.php only accepts one --type at a time, so we loop through them

cd /var/www/html

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
    php maintenance/runJobs.php --type="$job_type" --maxjobs=2 --maxtime=20 || true
  done
  
  # Small delay between cycles to avoid tight loops when no jobs available
  sleep 2
done

