## Develop on Windows and Jetson

### Windows (Docker Desktop)

1. Enable WSL2 backend (recommended).
2. Clone the repo into a path without spaces for smoother binds.
3. Start with `docker compose up -d --build`.
4. If bind mounts cause permission issues, switch to named volumes in `docker-compose.yml`.

### Ubuntu / NVIDIA Jetson (ARM64)

1. Install Docker Engine and Compose plugin.
2. (Optional) Enable Buildx/QEMU if building multi-arch from Jetson is needed.
3. Start with `docker compose up -d --build`.

### Multi-Arch Builds

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --name labki
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t labki/labki-wiki:dev .
```

### Useful Commands

```bash
# Shell into the wiki container
docker compose exec wiki bash

# Re-run installer (danger: overwrites)
docker compose exec wiki bash -lc "/install-mediawiki.sh"

# View MediaWiki version
docker compose exec wiki php maintenance/version.php
```

### Testing VisualEditor

- Create a page, open in VisualEditor, paste or drag an image to verify upload flow.

### Troubleshooting

- If VisualEditor fails to load, confirm MediaWiki version supports built-in Parsoid and check `MW_SERVER` matches the browser URL scheme/host.
- For short URLs, ensure `MW_SCRIPT_PATH` and `MW_SERVER` are set correctly; try hitting `/wiki/Special:Version`.


