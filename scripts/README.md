## Scripts Overview

Brief descriptions of each script used by the Labki MediaWiki stack.

- entrypoint.sh
  - Waits for the MariaDB service to become reachable on port 3306
  - On first run (no `config/LocalSettings.php`), runs the installer
  - Finally starts Apache (`apache2-foreground`)

- install-mediawiki.sh
  - Runs `php maintenance/install.php` using env vars (DB host/name/user/pass, site name, admin)
  - Moves generated `LocalSettings.php` into the persisted `config/` directory
  - Appends Labki defaults: uploads, short URLs, extensions (VisualEditor, PageForms, MsUpload, ParserFunctions, Cite), and Chameleon skin
  - Enables Semantic MediaWiki (SMW) and runs `maintenance/update.php --quick` to initialize/update DB tables

- init-db.sh
  - Optional helper that creates the database and user using MariaDB root credentials
  - Not required when the MariaDB container is configured via environment variables in `docker-compose.yml`

- backup.sh
  - Dumps the MariaDB database (gzipped SQL) and archives the `images/` upload directory
  - Intended to be run inside the wiki container or with access to the mounted paths


