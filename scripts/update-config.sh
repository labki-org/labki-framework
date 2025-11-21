#!/usr/bin/env bash
# update the settings within the container to reflect the `./config` directory

pushd /var/www/html >/dev/null

/bin/cp -f ./config/LocalSettings.php ./LocalSettings.php
echo "Updated LocalSettings.php from config/LocalSettings.php"

popd >/dev/null