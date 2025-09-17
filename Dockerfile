ARG MEDIAWIKI_VERSION=1.41
FROM mediawiki:${MEDIAWIKI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Fetch core extensions and skin (pinned shallow clones; pin to tags later)
RUN set -euxo pipefail; \
    git clone --depth 1 https://gerrit.wikimedia.org/r/mediawiki/extensions/VisualEditor extensions/VisualEditor; \
    git clone --depth 1 https://github.com/ProfessionalWiki/MsUpload.git extensions/MsUpload; \
    git clone --depth 1 https://github.com/ProfessionalWiki/chameleon.git skins/Chameleon

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


