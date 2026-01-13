This project is now archived. It has been moved over to 'labki-platform' and 'labki' repos in this same github org.

## Labki Framework

Labki is a customized, containerized MediaWiki distribution for lab knowledge management. This repository provides the base platform: a reproducible Docker image, a docker-compose setup (MediaWiki + MariaDB), curated extensions (including Semantic MediaWiki), a modern skin, and documentation to run on Windows (Docker Desktop), macOS (Docker Desktop), and Ubuntu/Jetson (ARM64).

### Status

- Base MediaWiki runs in Docker (Windows/macOS/Ubuntu/Jetson) with MariaDB, friendly URLs, and persistent config/uploads. Settings are layered via `config/LocalSettings.labki.php`.
- Extensions/skins listed below are planned; not yet installed by default. They will be added via Composer in subsequent steps.

### Features (initial scope)

- Dockerized MediaWiki with MariaDB
- Multi-arch builds (amd64, arm64) for Windows PCs, macOS, and NVIDIA Jetson
- Friendly URLs, uploads, and persistent storage
- Planned (not yet implemented): Semantic MediaWiki (SMW), VisualEditor, MsUpload, Chameleon skin (to be added via Composer)

### Repository Layout

```
labki-platform/
├── Dockerfile                  # Build the Labki MediaWiki image (multi-arch ready)
├── docker-compose.yml          # Bring up MediaWiki + MariaDB + volumes
├── .dockerignore               # Exclude unneeded files from Docker build context
├── .gitattributes              # Normalize line endings and file attributes
├── .github/
│   └── workflows/
│       ├── build.yml           # CI: build container on push/PR
│       └── test.yml            # CI: placeholder for extension tests
├── config/
│   ├── LocalSettings.labki.php      # Labki layered settings (tracked)
│   ├── LocalSettings.php.template   # Example template (informational)
│   ├── extra.php.example            # Optional overrides for local dev
│   └── secrets.env.example          # Example env vars (DB pwd, OAuth keys)
├── extensions/
│   └── labki-ext/              # Placeholder for Labki custom extension(s)
├── skins/
│   └── chameleon/              # Placeholder for Chameleon skin (installed during build)
├── images/                     # Empty dir; bind-mounted for uploads
├── scripts/
│   ├── init-db.sh              # Helper script for initializing DB (optional)
│   └── backup.sh               # Example script for DB+uploads backup
├── docs/
│   ├── INSTALL.md              # Step-by-step setup instructions
│   ├── DEVELOP.md              # Dev notes (Jetson, Windows, multi-arch builds)
│   └── CONTENT.md              # Guide for importing layouts/templates (future)
└── README.md                   # This file
```

### Prerequisites

- Windows/macOS: Docker Desktop (includes Docker Compose and Buildx)
- Ubuntu/Jetson:
  - Docker Engine and Docker Compose plugin
  - Buildx and QEMU emulation (for multi-arch builds)

Enable binfmt/QEMU once (Ubuntu/Jetson):

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --name labki
docker buildx inspect --bootstrap
```

### Quickstart (Windows/macOS with Docker Desktop)

```bash
git clone https://github.com/your-org/labki-platform.git
cd labki-platform
copy config\secrets.env.example config\secrets.env   # Windows PowerShell

# Or on macOS/Linux:
# cp config/secrets.env.example config/secrets.env

docker compose up -d

# Open http://localhost:8080
```

Notes:
- The initial stack mounts `./images` for uploads. `LocalSettings.php` will be generated during installation (steps in `docs/INSTALL.md`).
- On first run, you may be guided through MediaWiki’s installer. We will automate this in a later step using maintenance scripts.

### Quickstart (Ubuntu/NVIDIA Jetson – ARM64)

Option A: Build locally (multi-arch not required if building on Jetson):

```bash
git clone https://github.com/your-org/labki-platform.git
cd labki-platform
cp config/secrets.env.example config/secrets.env
docker compose up -d --build
# Open http://localhost:8080
```

Option B: Use a pre-built multi-arch image (when available):

```bash
docker pull labki/labki-wiki:dev
docker compose up -d
```

### Build Multi-Arch Image (from x86_64 host)

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t labki/labki-wiki:dev \
  .
```

### Configuration

- Copy `config/secrets.env.example` to `config/secrets.env` and adjust values.
- `docker-compose.yml` reads credentials from this file.
- First run: the installer generates `config/LocalSettings.php`, and the entrypoint appends an include to `config/LocalSettings.labki.php` (tracked) so Labki’s settings apply without overwriting the installer output.
- Paths: `$wgScriptPath = ""` (no `/w`), friendly URLs enabled.
- Planned: SMW, VisualEditor, MsUpload, and Chameleon via Composer (not yet installed by default).

### Documentation

- Installation guide: `docs/INSTALL.md`
- Developer notes (Windows/Jetson/multi-arch): `docs/DEVELOP.md`
- Content/Importer guidance (upcoming): `docs/CONTENT.md`
- Testing (local + GitHub Actions): `docs/TESTING.md`
- Overall plan: `LABKI_FRAMEWORK_INITIAL_SETUP_PLAN.md`

### Troubleshooting (common)

- Port in use: change `8080:80` mapping in `docker-compose.yml`.
- Permission issues on Windows bind mounts: run Docker Desktop as admin or switch to named volumes.
- Slow ARM builds: prefer pre-built multi-arch images when available.

### Reset options

- Reset config only (forces re-install on next start): set `LABKI_RESET=1` when starting `wiki`.
- Reset config + DB (requires root password in secrets): set `LABKI_RESET=1` and `LABKI_RESET_DB=1` when starting `wiki`.

### License

TBD. Default to a permissive open-source license for code. Content packs may use a Creative Commons license.


