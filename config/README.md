## Config Overview

Configuration files that are mounted into the MediaWiki container and persisted.

- LocalSettings.labki.php
  - Labki’s layered settings (tracked in git). Applied via an include from the generated `LocalSettings.php`.
  - Sets friendly URLs, uploads, and loads core extensions (ParserFunctions, Cite). Third-party extensions/skins are commented until installed via Composer.

- LocalSettings.php.template
  - Informational template only; not applied automatically. The installer generates `LocalSettings.php`, and the entrypoint appends an include for `LocalSettings.labki.php`.

- secrets.env.example
  - Example environment variables consumed by `docker-compose.yml`
  - Copy to `config/secrets.env` and customize (site name, admin credentials, DB credentials, MW server URL)

- extra.php.example
  - Optional PHP overrides for local development (e.g., higher upload limits, debug settings)
  - Can be included from `LocalSettings.php` if present

- LocalSettings.php (generated at first run)
  - Written by the installer to `config/LocalSettings.php`
  - Includes `require_once __DIR__ . '/config/LocalSettings.labki.php';`
  - Should be persisted and backed up; do not commit real secrets
