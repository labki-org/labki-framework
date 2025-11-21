#!/usr/bin/env bash

echo "[smw] Initial setup of SemanticMediaWiki"

echo "[install] Running maintenance/update.php (first pass)"
php maintenance/update.php --quick --conf config/LocalSettings.php || true

php extensions/SemanticMediaWiki/maintenance/setupStore.php --skip-optimize --conf config/LocalSettings.php

echo "[install] Running maintenance/update.php (second pass)"
php maintenance/update.php --quick --conf config/LocalSettings.php || true

if [ -d extensions/SemanticMediaWiki ]; then
  echo "[install] Running SMW setupStore.php to finalize schema"
  php extensions/SemanticMediaWiki/maintenance/setupStore.php --skip-optimize --conf config/LocalSettings.php
fi