ARG MEDIAWIKI_VERSION=1.44
FROM mediawiki:${MEDIAWIKI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip ca-certificates mariadb-client \
 && rm -rf /var/lib/apt/lists/*

# Fetch core extensions and skin (pinned shallow clones; pin to tags later)
## Extensions and skins are installed via Composer using composer.json

# Composer (available but not invoked during minimal bring-up)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY composer.local.json /var/www/html/composer.local.json

# Install/Update core dependencies via Composer
RUN composer update --no-dev --prefer-dist --no-interaction --no-progress

# Install MsUpload (REL1_44) via git (no composer.json in repo)
RUN set -eux; \
    mkdir -p extensions; \
    if [ ! -d extensions/MsUpload ]; then \
      git clone --depth=1 --branch REL1_44 https://github.com/wikimedia/mediawiki-extensions-MsUpload.git extensions/MsUpload; \
    fi;

# Install Citizen skin via git (no composer.json in repo)
RUN set -eux; \
    mkdir -p skins; \
    if [ ! -d skins/Citizen ]; then \
      git clone --depth=1 --branch v3.6.0 https://github.com/StarCitizenTools/mediawiki-skins-Citizen.git skins/Citizen; \
    fi;

# Fix ownership for webserver user
RUN chown -R www-data:www-data extensions/ skins/ vendor/

# Entrypoint + helper scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/install-mediawiki.sh /install-mediawiki.sh
RUN chmod +x /entrypoint.sh /install-mediawiki.sh

ENV APACHE_DOCUMENT_ROOT=/var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]


