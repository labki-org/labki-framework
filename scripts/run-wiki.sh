#!/usr/bin/env bash
set -euo pipefail

# First-run installation
bash /scripts/install-mediawiki.sh

apache2-foreground