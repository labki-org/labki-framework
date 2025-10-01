## Testing Labki Framework

This project includes CI smoke and end-to-end tests to ensure the Docker image builds and a MediaWiki instance boots with required extensions enabled (including LabkiPackManager).

### CI Tests

- Build workflow (`.github/workflows/build.yml`):
  - Builds the image (`labki/labki-wiki:ci`).
  - Smoke test: prints `php -v` from the image.
  - E2E job: starts MariaDB, runs the wiki container, waits for `/wiki/Main_Page`, asserts `Special:Version` lists `LabkiPackManager`, and runs `maintenance/update.php`.

You can view CI runs on GitHub Actions under the “build” workflow.

### Run E2E tests locally

1) Build locally:
```bash
docker build -t labki/labki-wiki:ci .
```

2) Start MariaDB:
```bash
docker network create labki-ci || true
docker run -d --name labki-ci-db --network labki-ci \
  -e MARIADB_DATABASE=labki \
  -e MARIADB_USER=labki \
  -e MARIADB_PASSWORD=labki_pass \
  -e MARIADB_ROOT_PASSWORD=root_pass \
  mariadb:10.6
for i in {1..60}; do docker exec labki-ci-db mysql -ulabki -plabki_pass -e "SELECT 1" && break || sleep 2; done
```

3) Run the wiki:
```bash
docker run -d --name labki-ci-wiki --network labki-ci -p 8080:80 \
  -e MW_SITE_NAME=Labki \
  -e MW_SITE_LANG=en \
  -e MW_ADMIN_USER=admin \
  -e MW_ADMIN_PASS=SiwdonDWoi827D \
  -e MW_DB_NAME=labki \
  -e MW_DB_USER=labki \
  -e MW_DB_PASSWORD=labki_pass \
  -e MW_SERVER=http://localhost:8080 \
  -e MEDIAWIKI_VERSION=1.44 \
  -e LABKI_DEBUG=1 \
  labki/labki-wiki:ci
for i in {1..60}; do curl -fsS http://localhost:8080/wiki/Main_Page && break || sleep 2; done
```

4) Assertions:
```bash
curl -fsS "http://localhost:8080/index.php?title=Special:Version" | grep -q 'LabkiPackManager'
docker exec labki-ci-wiki php /var/www/html/maintenance/update.php --quick --conf /var/www/html/config/LocalSettings.php
```

5) Cleanup:
```bash
docker rm -f labki-ci-wiki || true
docker rm -f labki-ci-db || true
docker network rm labki-ci || true
```

### Notes

- The E2E test uses environment variables similar to `config/secrets.env`. It intentionally avoids bind mounts so the container performs its own first-run install and `LocalSettings` wiring.
- If you need verbose debugging, set `LABKI_DEBUG=1` (already used above).


