## Install Labki (Docker Compose)

### 1) Prerequisites

- Windows/macOS: Docker Desktop
- Ubuntu/Jetson: Docker Engine + Compose plugin; optional Buildx/QEMU for multi-arch

### 2) Clone and configure

```bash
git clone https://github.com/your-org/labki-platform.git
cd labki-platform
cp config/secrets.env.example config/secrets.env
```

Edit `config/secrets.env` for site name, admin credentials, and DB passwords.

### 3) Start the stack

```bash
docker compose --env-file config/secrets.env up -d --build
```

Open `http://localhost:8080`.

On first run, the container installs MediaWiki and writes `config/LocalSettings.php`.

### 4) Verify extensions and skin

- Special:Version should list VisualEditor, PageForms, MsUpload, ParserFunctions, Cite.
- Switch skin to Chameleon under Preferences.

### 5) Persistence

- Uploads are stored in `./images`.
- `config/` is bind-mounted to persist `LocalSettings.php`.

### 6) Common operations

```bash
docker compose logs -f wiki
docker compose restart wiki
docker compose down
```


