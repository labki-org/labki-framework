## Config Overview

Configuration files that are mounted into the MediaWiki container and persisted.

- LocalSettings.php.template
  - Base Labki configuration template (no secrets)
  - Loads core extensions (ParserFunctions, Cite, PageForms, VisualEditor, MsUpload) and the Chameleon skin
  - Enables Semantic MediaWiki (SMW) and `enableSemantics(...)`
  - Used as reference/merge when generating the runtime `LocalSettings.php`

- secrets.env.example
  - Example environment variables consumed by `docker-compose.yml`
  - Copy to `config/secrets.env` and customize (site name, admin credentials, DB credentials, MW server URL)

- extra.php.example
  - Optional PHP overrides for local development (e.g., higher upload limits, debug settings)
  - Can be included from `LocalSettings.php` if present

- LocalSettings.php (generated at first run)
  - Written by the installer to `config/LocalSettings.php`
  - Should be persisted and backed up; do not commit real secrets
