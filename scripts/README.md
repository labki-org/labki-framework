## Scripts Overview

Brief descriptions of each script used by the Labki MediaWiki stack.

- entrypoint.sh
  - Authenticated DB wait (ensures credentials work)
  - Optional reset flags: `LABKI_RESET=1` (reset config) and `LABKI_RESET_DB=1` (also reset DB)
  - First run: runs installer; existing config + fresh DB: re-runs installer automatically
  - Normalizes DB settings in `config/LocalSettings.php`, syncs to docroot, then starts Apache

- install-mediawiki.sh
  - Runs `php maintenance/install.php` using env vars
  - Moves generated `LocalSettings.php` into `config/`
  - Appends `require_once __DIR__ . '/config/LocalSettings.labki.php';` to layer tracked Labki settings

- init-db.sh
  - Optional helper that creates the database and user using MariaDB root credentials
  - Not required when the MariaDB container is configured via environment variables in `docker-compose.yml`

- backup.sh
  - Dumps the MariaDB database (gzipped SQL) and archives the `images/` upload directory
  - Intended to be run inside the wiki container or with access to the mounted paths


