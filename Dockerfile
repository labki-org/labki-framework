ARG MEDIAWIKI_VERSION=1.41
FROM mediawiki:${MEDIAWIKI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Fetch core extensions and skin (pinned shallow clones; pin to tags later)
## Extensions and skins are installed via Composer using composer.json

# Composer (available but not invoked during minimal bring-up)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
# COPY composer.local.json /var/www/html/composer.local.json

# Entrypoint + helper scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/install-mediawiki.sh /install-mediawiki.sh
RUN chmod +x /entrypoint.sh /install-mediawiki.sh

ENV APACHE_DOCUMENT_ROOT=/var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]


