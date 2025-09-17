## Labki Framework – Initial Setup Development Plan

This plan describes the concrete, actionable steps to bootstrap the Labki framework: a Dockerized, version-controlled MediaWiki distribution with curated extensions, a modern skin, and foundations for future Labki custom extensions and content packs. It focuses on initial platform setup, repeatable builds, and a smooth out‑of‑the‑box experience on Ubuntu (including NVIDIA Jetson ARM64) and other hosts.

---

### Scope and Goals

- **Objective**: Deliver a reproducible base platform (Docker image + Compose) for MediaWiki configured for Labki, including initial extensions (VisualEditor, PageForms, MsUpload, ParserFunctions, Cite, Semantic MediaWiki), a modern skin (Chameleon or alternative), friendly URLs, uploads, and persistence.
- **Out of scope (initial phase)**: Implementing custom Labki importer extensions and publishing the content repository. We will, however, prepare placeholders and configuration hooks.
 - **Cross-platform target**: Development and usage on Windows (Docker Desktop), macOS (Docker Desktop), and Ubuntu/NVIDIA Jetson (ARM64) with parity.

---

### High-Level Outcomes (Acceptance Criteria)

- **AC1 – Reproducible build**: `docker buildx build` produces a multi-arch image (amd64/arm64) tagged `labki/labki-wiki:dev` from this repo.
- **AC2 – One-command run**: `docker compose up -d` starts MediaWiki (web) and MariaDB, with persistent volumes for `/images`, `LocalSettings.php`, and DB data.
- **AC3 – Guided first run**: On first boot, automatic CLI install seeds `LocalSettings.php` from environment variables. Wiki is reachable at `http://localhost:8080/` (configurable) and has an admin user.
- **AC4 – Extensions working**: VisualEditor (using built-in Parsoid), PageForms, MsUpload, ParserFunctions, and Cite are enabled and functioning.
- **AC5 – Skin applied**: Chameleon (or fallback skin) is installed, selectable, and set as default; site is responsive.
- **AC6 – Friendly URLs**: Pages are accessible without `?title=`, e.g., `/wiki/Main_Page`.
- **AC7 – Persistence**: File uploads and DB survive container restarts; configuration is re-usable across rebuilds.
- **AC8 – Documentation**: Clear READMEs for build/run, configuration, and troubleshooting are present in-repo.
 - **AC9 – Semantic MediaWiki operational**: SMW is installed via Composer, enabled, database schema initialized, and Special:Version/Special:SMWAdmin confirm correct operation.

---

### Technology and Versioning Decisions

- **MediaWiki version**: Pin to the latest stable or LTS at implementation time (e.g., 1.41.x). Expose as `MEDIAWIKI_VERSION` build arg for easy upgrades.
- **Base image**: Start `FROM mediawiki:${MEDIAWIKI_VERSION}-apache` (official image includes PHP + Apache, supports multi-arch).
- **Database**: MariaDB 10.6+ in a separate container.
- **ARM64**: Use Docker Buildx with QEMU to build multi-arch images for Jetson compatibility.
- **Secrets**: Provide via `.env` and Compose; do not bake credentials into the image.
 - **Semantic MediaWiki**: Pin to a compatible SMW major/minor (e.g., `~4.1` at implementation time) and install via Composer during Docker build for deterministic versions.

---

### Repository Structure (initial)

```
.
├─ Dockerfile
├─ compose.yaml
├─ .env.example
├─ config/
│  ├─ LocalSettings.template.php
│  ├─ php.ini (optional overrides)
│  └─ apache.conf (optional extra config)
├─ scripts/
│  ├─ entrypoint.sh
│  ├─ install-mediawiki.sh
│  └─ healthcheck.sh
├─ docs/
│  ├─ RUNBOOK.md
│  └─ TROUBLESHOOTING.md
├─ .github/workflows/
│  └─ ci.yml (initial smoke build)
└─ LABKI_FRAMEWORK_INITIAL_SETUP_PLAN.md (this file)
```

Notes:
- We mount `config/` at runtime so `LocalSettings.php` can persist outside the container.
- `scripts/` contains idempotent install/start logic.

---

### Environment and Prerequisites

- **On Ubuntu/Jetson**: Docker, Docker Compose plugin, Buildx (`docker buildx create --use`), and QEMU (`docker run --privileged --rm tonistiigi/binfmt --install all`).
- **On other hosts (Windows/macOS)**: Docker Desktop (includes Buildx and Compose). ARM64 images still build via Buildx.

---

### Docker Image Design

- **Base**: `mediawiki:${MEDIAWIKI_VERSION}-apache`.
- **Install extensions and skin** during build to lock versions:
  - VisualEditor (core Parsoid config; no external Parsoid service on modern MW).
  - PageForms
  - MsUpload
  - ParserFunctions (often bundled; ensure enabled)
  - Cite (ensure enabled)
  - Chameleon skin (Bootstrap dependencies via Composer)
- **Semantic MediaWiki**: Install via Composer (`composer require mediawiki/semantic-media-wiki:"~4.1"`) in the MediaWiki root; enable in `LocalSettings.php`; run `maintenance/update.php` on first start to initialize SMW tables.
- **Composer**: Use the image’s composer (or install) to fetch dependencies for Chameleon and any PHP libraries.
- **Config hooks**: Copy `entrypoint.sh` and `install-mediawiki.sh` into the image; set as entrypoint/CMD.

Example Dockerfile (illustrative snippets; full file will be implemented in repo):

```Dockerfile
ARG MEDIAWIKI_VERSION=1.41
FROM mediawiki:${MEDIAWIKI_VERSION}-apache

# Install tools needed for building extensions and composer
RUN apt-get update && apt-get install -y \
    git unzip locales && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# VisualEditor, PageForms, MsUpload (pin to tags/commits as needed)
RUN set -eux; \
    git clone --depth 1 https://gerrit.wikimedia.org/r/mediawiki/extensions/VisualEditor extensions/VisualEditor; \
    git clone --depth 1 https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms extensions/PageForms; \
    git clone --depth 1 https://github.com/ProfessionalWiki/MsUpload.git extensions/MsUpload

# Commonly used core-bundled extensions: ensure directories exist (or clone if needed)
# ParserFunctions and Cite are maintained in Gerrit; for modern MW they’re usually available.

# Chameleon skin + dependencies
RUN git clone --depth 1 https://github.com/ProfessionalWiki/chameleon.git skins/Chameleon

# Install PHP deps for Chameleon via composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev -d skins/Chameleon

# Semantic MediaWiki via Composer (pin version appropriately)
RUN composer require --no-interaction --no-dev mediawiki/semantic-media-wiki:"~4.1" || true

# Copy entrypoint and install scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/install-mediawiki.sh /install-mediawiki.sh
RUN chmod +x /entrypoint.sh /install-mediawiki.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
```

---

### Compose Topology and Persistence

```yaml
services:
  wiki:
    build:
      context: .
      args:
        MEDIAWIKI_VERSION: ${MEDIAWIKI_VERSION}
    image: labki/labki-wiki:dev
    ports:
      - "8080:80"
    environment:
      MW_SITE_NAME: ${MW_SITE_NAME}
      MW_SITE_LANG: ${MW_SITE_LANG}
      MW_ADMIN_USER: ${MW_ADMIN_USER}
      MW_ADMIN_PASS: ${MW_ADMIN_PASS}
      MW_DB_NAME: ${MW_DB_NAME}
      MW_DB_USER: ${MW_DB_USER}
      MW_DB_PASSWORD: ${MW_DB_PASSWORD}
      MW_DB_HOST: db
      MW_SERVER: ${MW_SERVER}
      MW_SCRIPT_PATH: /w
      MW_LOG_LEVEL: ${MW_LOG_LEVEL:-warning}
    volumes:
      - mediawiki-images:/var/www/html/images
      - mediawiki-config:/var/www/html/config
    depends_on:
      - db

  db:
    image: mariadb:10.6
    environment:
      MARIADB_DATABASE: ${MW_DB_NAME}
      MARIADB_USER: ${MW_DB_USER}
      MARIADB_PASSWORD: ${MW_DB_PASSWORD}
      MARIADB_ROOT_PASSWORD: ${MARIADB_ROOT_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql

volumes:
  mediawiki-images:
  mediawiki-config:
  db-data:
```

`.env.example`:

```env
MEDIAWIKI_VERSION=1.41
MW_SITE_NAME=Labki
MW_SITE_LANG=en
MW_ADMIN_USER=admin
MW_ADMIN_PASS=changeme
MW_DB_NAME=labki
MW_DB_USER=labki
MW_DB_PASSWORD=labki_pass
MARIADB_ROOT_PASSWORD=root_pass
MW_SERVER=http://localhost:8080
```

---

### Installation Flow (Container Entrypoint)

- On container start, `entrypoint.sh` should:
  - Wait for DB readiness (with retries).
  - If `/var/www/html/config/LocalSettings.php` is missing, run `install-mediawiki.sh` (MediaWiki maintenance `install.php`) using env vars, writing `LocalSettings.php` into `config/`.
  - After enabling extensions (including SMW), run `php maintenance/update.php` to apply database schema updates (this initializes SMW store tables).
  - Ensure Apache rewrites are enabled and friendly URL config present.
  - Exec `apache2-foreground`.

`install-mediawiki.sh` (concept):

```bash
#!/usr/bin/env bash
set -euo pipefail

php maintenance/install.php \
  --dbtype mysql \
  --dbname "$MW_DB_NAME" \
  --dbserver "$MW_DB_HOST" \
  --dbuser "$MW_DB_USER" \
  --dbpass "$MW_DB_PASSWORD" \
  --installdbuser root \
  --installdbpass "$MARIADB_ROOT_PASSWORD" \
  --server "$MW_SERVER" \
  --scriptpath "$MW_SCRIPT_PATH" \
  --lang "$MW_SITE_LANG" \
  --pass "$MW_ADMIN_PASS" \
  "$MW_SITE_NAME" "$MW_ADMIN_USER"

# Move LocalSettings.php to persistent config and post-configure
mv LocalSettings.php config/LocalSettings.php
```

---

### LocalSettings Template and Post-Configuration

After installation, append Labki-specific configuration to `config/LocalSettings.php` or include a separate `ConfigLabki.php` file. Key settings:

- **Uploads**: `$wgEnableUploads = true;` and allowed file types/size.
- **Friendly URLs**: set `$wgArticlePath = "/wiki/$1";` and configure Apache rewrite.
- **Default skin**: `$wgDefaultSkin = 'chameleon';` (fallback to `vector-2022` if unavailable).
- **Extensions**:
  ```php
  wfLoadExtension( 'VisualEditor' );
  wfLoadExtension( 'PageForms' );
  wfLoadExtension( 'MsUpload' );
  wfLoadExtension( 'ParserFunctions' );
  wfLoadExtension( 'Cite' );
  wfLoadSkin( 'Chameleon' );
  ```
- **VisualEditor/Parsoid** (modern config):
  ```php
  $wgDefaultUserOptions['visualeditor-enable'] = 1;
  $wgVisualEditorEnableWikitext = true;
  $wgVisualEditorAvailableNamespaces = [ NS_MAIN => true, NS_TEMPLATE => true, NS_PROJECT => true ];
  ```
- **MsUpload** basic defaults (optional): limit and namespaces.

We will implement the template as `config/LocalSettings.template.php` and have the installer append/merge Labki settings idempotently.

Add SMW configuration and enablement:
```php
wfLoadExtension( 'SemanticMediaWiki' );
enableSemantics( parse_url( getenv('MW_SERVER') ?: 'http://localhost:8080', PHP_URL_HOST ) ?: 'localhost' );
```

---

### Skins and Theming

- **Primary**: Chameleon (Bootstrap-based, flexible).
- **Alternatives**: Medik or Timeless (simpler, maintained). Keep at least one fallback skin installed.
- **Assets**: Add site logo via `$wgLogo` and configure navigation per skin guidelines.

---

### HTTP Routing and Friendly URLs (Apache)

- Enable `mod_rewrite` (provided by base image) and include `.htaccess` or vhost rules. The official image supports short URLs with proper config of `$wgScriptPath` and `$wgArticlePath`.
- Validate by accessing `/wiki/Main_Page`.

---

### Multi-Arch Build and Publishing

- Initialize Buildx and binfmt (one-time):
  ```bash
  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx create --use --name labki
  docker buildx inspect --bootstrap
  ```
- Build multi-arch image:
  ```bash
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t labki/labki-wiki:dev \
    --build-arg MEDIAWIKI_VERSION=1.41 \
    .
  ```
- Optionally push to registry on tag.

---

### CI (Initial)

- GitHub Actions workflow:
  - Lint shell scripts (`shellcheck`).
  - Build image for native arch (no push) to catch Dockerfile errors.
  - Optionally run container and curl health endpoint.
  - (Optional) Run `php maintenance/update.php --quick` inside container to validate SMW tables can be created.

Example matrix (to be implemented in `.github/workflows/ci.yml`).

---

### Operational Docs

- `docs/RUNBOOK.md`: Start/stop, upgrade, backup/restore (mysqldump and images volume), troubleshooting.
- `docs/TROUBLESHOOTING.md`: VisualEditor issues, permission fixes, file upload limits, friendly URL pitfalls.
  - Include a note for SMW initialization and `Special:SMWAdmin` maintenance tasks.

---

### Security and Permissions

- Restrict importer/admin actions to `sysop` (future Labki extensions).
- Enforce HTTPS in production via reverse proxy (future phase). For dev, HTTP is acceptable.
- Do not commit `.env` with secrets; provide `.env.example`.

---

### Risks and Mitigations

- **VisualEditor complexity**: Use built-in Parsoid (new MW versions) to avoid external service; document known caveats.
- **Skin dependencies**: Lock Chameleon and Composer deps to tags; add fallback skin.
- **ARM64 quirks**: Validate on Jetson early; use multi-arch builds.
- **Extension compatibility**: Pin extension commits compatible with chosen MW version.

---

### Milestones and Tasks

- **M0 – Scaffold repo (0.5d)**
  - Add `Dockerfile`, `compose.yaml`, `.env.example`, `scripts/`, `config/LocalSettings.template.php`, docs stubs.

- **M1 – Bring up core MediaWiki (1d)**
  - Implement entrypoint + install script; confirm AC2–AC3 on amd64.

- **M2 – Extensions & skin (1–1.5d)**
  - Install and enable VisualEditor, PageForms, MsUpload, ParserFunctions, Cite, Semantic MediaWiki; install Chameleon; set defaults; initialize SMW store via `maintenance/update.php`.

- **M3 – Friendly URLs & uploads (0.5d)**
  - Validate short URLs and file uploads; tune limits.

- **M4 – Multi-arch build (0.5–1d)**
  - Build and run on Jetson; fix arm64 issues.

- **M5 – CI and docs (0.5d)**
  - Add GitHub Actions smoke build; write RUNBOOK and TROUBLESHOOTING.

---

### Manual Validation Checklist

- Access homepage and log in as admin.
- Create a page with VisualEditor, paste/drag an image; image uploads to `/images`.
- Create a simple Page Forms form and use “Edit with form”.
- Switch skins between Chameleon and Vector; confirm responsive layout.
- Restart containers; confirm pages and uploads persist.
- Visit `Special:Version` and verify Semantic MediaWiki is listed.
- Visit `Special:SMWAdmin` and ensure the store reports no pending setup tasks.

---

### Future Hooks (Next Phases, Not Implemented Here)

- Custom Labki importer extensions: register `Special:LabkiImports`, define `labki-import` right, implement manifest fetch and XML import using `WikiImporter`.
- Content repository (`labki-content`): structure `layouts/`, `templates/`, `manifest.json`; pin raw manifest URL in config.
- CI for extensions: PHPUnit, PHPCS, and integration smoke tests inside MediaWiki docker.

---

### Quickstart (Once Implemented)

```bash
cp .env.example .env
docker compose build
docker compose up -d
open http://localhost:8080
```

If running on Jetson, prefer a pre-built `linux/arm64` image or use Buildx with `--platform linux/arm64`.

---

This document will evolve as we implement the scaffold. All changes should keep AC1–AC8 passing.


