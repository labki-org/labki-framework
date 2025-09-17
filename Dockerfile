ARG MEDIAWIKI_VERSION=1.41
FROM mediawiki:${MEDIAWIKI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# Fetch core extensions and skin (pinned shallow clones; pin to tags later)
RUN set -euxo pipefail; \
    if [ ! -d extensions/VisualEditor ]; then git clone --depth 1 https://gerrit.wikimedia.org/r/mediawiki/extensions/VisualEditor extensions/VisualEditor; fi; \
    if [ ! -d extensions/MsUpload ]; then \
      mkdir -p /tmp/msupload && \
      (curl -fsSL -o /tmp/msupload/MsUpload.zip https://codeload.github.com/ProfessionalWiki/MsUpload/zip/refs/heads/master || \
       curl -fsSL -o /tmp/msupload/MsUpload.zip https://codeload.github.com/ProfessionalWiki/MsUpload/zip/refs/heads/main) && \
      unzip -q /tmp/msupload/MsUpload.zip -d /tmp/msupload && \
      msdir=$(find /tmp/msupload -maxdepth 1 -type d -name 'MsUpload-*' | head -n 1) && \
      mkdir -p extensions && mv "$msdir" extensions/MsUpload && rm -rf /tmp/msupload; \
    fi; \
    if [ ! -d skins/Chameleon ]; then \
      mkdir -p /tmp/chameleon && \
      (curl -fsSL -o /tmp/chameleon/Chameleon.zip https://codeload.github.com/ProfessionalWiki/chameleon/zip/refs/heads/master || \
       curl -fsSL -o /tmp/chameleon/Chameleon.zip https://codeload.github.com/ProfessionalWiki/chameleon/zip/refs/heads/main) && \
      unzip -q /tmp/chameleon/Chameleon.zip -d /tmp/chameleon && \
      chdir=$(find /tmp/chameleon -maxdepth 1 -type d -name 'chameleon-*' | head -n 1) && \
      mkdir -p skins && mv "$chdir" skins/Chameleon && rm -rf /tmp/chameleon; \
    fi

# Composer for Chameleon dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev -d skins/Chameleon || true

# Install Semantic MediaWiki via Composer (pin appropriate version)
RUN composer require --no-interaction --no-dev mediawiki/semantic-media-wiki:"~4.1" || true

# Entrypoint + helper scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/install-mediawiki.sh /install-mediawiki.sh
RUN chmod +x /entrypoint.sh /install-mediawiki.sh

ENV APACHE_DOCUMENT_ROOT=/var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]


