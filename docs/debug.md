## Debugging Docker and MediaWiki in Labki

Use these steps to diagnose build/startup problems and runtime errors.

### Quick checklist
- Is the `wiki` container running (not restarting)?
- Do logs show a PHP/extension/skin error?
- Was `config/LocalSettings.php` created by the installer?
- Does `Special:Version` list expected extensions/skins?

### Check container status
Windows (PowerShell):
```powershell
docker compose ps
```
macOS/Linux:
```bash
docker compose ps
```
If the `wiki` container is `restarting`, check logs next.

### View logs
Windows (PowerShell):
```powershell
docker compose logs --no-color --tail=200 wiki
```
macOS/Linux:
```bash
docker compose logs --tail=200 wiki
```
Follow logs:
```bash
docker compose logs -f wiki
```
Database logs (if needed):
```bash
docker compose logs --tail=200 db
```

Common restart-loop pattern:
- Incompatible extension/skin version. Example:
  "Skin/extension is not compatible with the current MediaWiki core"
  - Fix by upgrading MediaWiki, pinning to a compatible branch/tag, or disabling the skin/extension.

### Exec into the container
Windows/macOS/Linux:
```bash
docker compose exec -T wiki bash
```
Inside the container:
```bash
set -e
cd /var/www/html
ls -l
ls -l config || true
php -v
apache2ctl -V 2>/dev/null || true
```

### Verify installer and LocalSettings.php
`LocalSettings.php` is created at runtime by `scripts/install-mediawiki.sh`, triggered by `scripts/entrypoint.sh` on first start.

Inside the container:
```bash
ls -l config
[ -f config/LocalSettings.php ] && grep -n "LocalSettings.labki.php" config/LocalSettings.php || true
[ -f LocalSettings.php ] && grep -n "LocalSettings.labki.php" LocalSettings.php || true
```
If `config/LocalSettings.php` is missing:
- Check `wiki` logs for installer errors.
- Ensure DB is reachable (see DB check below).

### Force a clean reinstall (dev only)
PowerShell:
```powershell
$env:LABKI_RESET='1'
docker compose up -d wiki
```
Also reset the DB (requires `MARIADB_ROOT_PASSWORD` in `config/secrets.env`):
```powershell
$env:LABKI_RESET='1'
$env:LABKI_RESET_DB='1'
docker compose up -d wiki
```
Unset variables (or open a new shell) afterwards.

### Rebuild image
Rebuild and start:
```bash
docker compose up -d --build
```
If cache masks changes:
```bash
docker compose build --no-cache wiki && docker compose up -d wiki
```

Composer build failures usually indicate:
- Missing/invalid package metadata.
- Installing from a VCS repo without a `composer.json` (install via `git clone` in the Dockerfile instead).
- Version conflicts (extension/skin requires a newer MediaWiki).

### MediaWiki diagnostics
- Enable debug toggles via `LABKI_DEBUG=1` (wired in `config/LocalSettings.labki.php`):
  - `$wgShowExceptionDetails = true;`
  - `$wgDebugToolbar = true;`
  - `$wgResourceLoaderDebug = true;`

Temporary run with extra env var:
```bash
docker compose run --rm -e LABKI_DEBUG=1 wiki true
```
Then start normally.

- Visit `Special:Version` to confirm installed extensions/skins.
- For VisualEditor/MsUpload issues, open browser DevTools → Console/Network.

### Web/PHP error visibility
The official `mediawiki` image logs Apache/PHP errors to stdout/stderr → use `docker compose logs wiki`.
Optionally check inside container:
```bash
ls -l /var/log/apache2 2>/dev/null || true
```

### Maintenance scripts
Run from container root `/var/www/html`:
```bash
docker compose exec -T wiki bash -lc "set -e; cd /var/www/html; php maintenance/update.php --quick"
```
Job queue:
```bash
docker compose exec -T wiki bash -lc "cd /var/www/html; php maintenance/showJobs.php; php maintenance/runJobs.php --maxjobs 100"
```

### Database connectivity check
From the wiki container:
```bash
docker compose exec -T wiki bash -lc "MYSQL_PWD=\"${MW_DB_PASSWORD:-labki_pass}\" mysql -h \"${MW_DB_HOST:-db}\" -u \"${MW_DB_USER:-labki}\" -e 'SELECT 1'"
```

### File ownership and bind mounts
- The image sets `www-data` ownership for `extensions/`, `skins/`, `vendor/` during build.
- Bind-mounted `./images` and `./config` can still hit host permission quirks—on Windows, consider switching to named volumes if writes fail.

### When asking for help
Provide:
- Output of `docker compose ps` and `docker compose logs --tail=200 wiki`.
- MediaWiki version and relevant lines from `config/LocalSettings.php` (no secrets).
- Recent diffs to `Dockerfile` and `composer.local.json`.
