## Install Labki (Docker Compose)

### 1) Prerequisites

- Windows/macOS: Docker Desktop (WSL2 backend recommended on Windows)
- Ubuntu/Jetson: Docker Engine + Compose plugin; optional Buildx/QEMU for multi-arch

### 2) Clone and configure

Windows (PowerShell):
```powershell
git clone https://github.com/Aharoni-Lab/labki-framework.git
cd labki-framework
copy config\secrets.env.example config\secrets.env
```

macOS/Linux:
```bash
git clone https://github.com/Aharoni-Lab/labki-framework.git
cd labki-framework
cp config/secrets.env.example config/secrets.env
```

Edit `config/secrets.env` for site name, admin credentials, and DB passwords. Ensure `MW_SERVER` matches your browser URL (e.g., `http://localhost:8080`).

### 3) Start the stack

Windows (PowerShell):
```powershell
docker compose --env-file config\secrets.env up -d --build
```

macOS/Linux:
```bash
docker compose --env-file config/secrets.env up -d --build
```

Open `http://localhost:8080` (root) and `http://localhost:8080/index.php/Main_Page`.

On first run, the container installs MediaWiki and writes `config/LocalSettings.php`.

### 4) Verify extensions and features

- Special:Version should list ParserFunctions, Cite, VisualEditor, and MsUpload.
- In the wikitext editor, drag-and-drop multiple files to upload (MsUpload).
- Semantic MediaWiki (SMW) is not installed by default.
- Optional: Switch skin to Chameleon under Preferences (if installed).

### 5) Persistence

- Uploads are stored in `./images`.
- `config/` is bind-mounted to persist `LocalSettings.php`.

### 6) Common operations

Windows (PowerShell):
```powershell
docker compose logs -f wiki
docker compose restart wiki
docker compose down
```

macOS/Linux:
```bash
docker compose logs -f wiki
docker compose restart wiki
docker compose down
```

### 7) Troubleshooting (Windows)

- If bind-mount permissions cause issues, switch `./images` and `./config` to named volumes in `docker-compose.yml`.
- Ensure `.sh` files have LF endings (repo enforces via `.gitattributes`).
- If styles look broken, ensure `$wgScriptPath = ""` in `config/LocalSettings.php`, then restart `docker compose up -d wiki` and hard refresh with cache disabled.
- If VisualEditor fails to load later, confirm `MW_SERVER` matches `http://localhost:8080` and retry.

### 8) Optional reset flags

For a clean reinstall without manually deleting files:

```powershell
# Reset LocalSettings and re-install on next start
$env:LABKI_RESET = '1'
docker compose up -d wiki

# Also reset the DB (requires root password in config/secrets.env)
$env:LABKI_RESET = '1'
$env:LABKI_RESET_DB = '1'
docker compose up -d wiki
```

Unset the variables (or open a new shell) for normal operation afterward.


