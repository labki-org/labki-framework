ARG MEDIAWIKI_VERSION=1.41
FROM mediawiki:${MEDIAWIKI_VERSION}

# Pin refs for external extensions/skins (override at build-time)
ARG MW_EXT_BRANCH=REL1_41
ARG MSUPLOAD_REF=main
ARG CHAMELEON_REF=master

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# Fetch core extensions and skin (pinned shallow clones; pin to tags later)
RUN set -euxo pipefail; \
    # VisualEditor: pin to MediaWiki branch (REL1_41 by default)
    if [ ! -d extensions/VisualEditor ]; then \
      git clone --depth 1 --branch "$MW_EXT_BRANCH" https://gerrit.wikimedia.org/r/mediawiki/extensions/VisualEditor extensions/VisualEditor; \
    fi; \
    # MsUpload: fetch specific ref (default: main) via codeload
    if [ ! -d extensions/MsUpload ]; then \
      mkdir -p /tmp/msupload && \
      curl -fsSL -o /tmp/msupload/MsUpload.zip "https://codeload.github.com/ProfessionalWiki/MsUpload/zip/refs/heads/${MSUPLOAD_REF}" && \
      unzip -q /tmp/msupload/MsUpload.zip -d /tmp/msupload && \
      msdir=$(find /tmp/msupload -maxdepth 1 -type d -name 'MsUpload-*' | head -n 1) && \
      mkdir -p extensions && mv "$msdir" extensions/MsUpload && rm -rf /tmp/msupload; \
    fi; \
    # Chameleon: fetch specific ref (default: master) and install PHP deps via composer below
    if [ ! -d skins/Chameleon ]; then \
      mkdir -p /tmp/chameleon && \
      curl -fsSL -o /tmp/chameleon/Chameleon.zip "https://codeload.github.com/ProfessionalWiki/chameleon/zip/refs/heads/${CHAMELEON_REF}" && \
      unzip -q /tmp/chameleon/Chameleon.zip -d /tmp/chameleon && \
      chdir=$(find /tmp/chameleon -maxdepth 1 -type d -name 'chameleon-*' | head -n 1) && \
      mkdir -p skins && mv "$chdir" skins/Chameleon && rm -rf /tmp/chameleon; \
    fi

# Composer for Chameleon dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
# Install Chameleon skin dependencies
RUN composer install --no-dev -d skins/Chameleon || true

# Install project-level composer deps (e.g., Semantic MediaWiki)
COPY composer.json /var/www/html/composer.json
RUN composer install --no-dev || true

# Entrypoint + helper scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/install-mediawiki.sh /install-mediawiki.sh
RUN chmod +x /entrypoint.sh /install-mediawiki.sh

ENV APACHE_DOCUMENT_ROOT=/var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]


