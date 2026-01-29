ARG MEDIAWIKI_VERSION=1.44
FROM mediawiki:${MEDIAWIKI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip ca-certificates mariadb-client \
 && rm -rf /var/lib/apt/lists/*

# Composer (available in the image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Clone extensions BEFORE composer update so merge-plugin can include their composer.json files
RUN set -eux; \
    mkdir -p extensions; \
    if [ ! -d extensions/MsUpload ]; then \
      git clone --depth=1 --branch REL1_44 https://github.com/wikimedia/mediawiki-extensions-MsUpload.git extensions/MsUpload; \
    fi; \
    if [ ! -d extensions/LabkiPackManager ]; then \
      git clone --depth=1 --branch main https://github.com/Aharoni-Lab/LabkiPackManager.git extensions/LabkiPackManager; \
    fi

RUN set -eux; \
  mkdir -p extensions; \
  if [ ! -d extensions/PageSchemas ]; then \
    git clone --depth=1 --branch REL1_44 https://gerrit.wikimedia.org/r/mediawiki/extensions/PageSchemas.git extensions/PageSchemas; \
  fi; \
  if [ ! -d extensions/Lockdown ]; then \
    git clone --depth=1 --branch REL1_44 https://gerrit.wikimedia.org/r/mediawiki/extensions/Lockdown.git extensions/Lockdown; \
  fi

# Provide composer.local.json that enables wikimedia/composer-merge-plugin and includes extensions/*/composer.json
COPY composer.local.json /var/www/html/composer.local.json

# Install/Update core + extensions dependencies via Composer (includes LabkiPackManager deps)
RUN composer update --no-dev --prefer-dist --no-interaction --no-progress

# Include layered Labki settings so installer include works in CI (no bind mount)
COPY config/LocalSettings.labki.php /var/www/html/config/LocalSettings.labki.php

# Install Citizen skin via git (no composer.json in repo)
RUN set -eux; \
    mkdir -p skins; \
    if [ ! -d skins/Citizen ]; then \
      git clone --depth=1 --branch v3.6.0 https://github.com/StarCitizenTools/mediawiki-skins-Citizen.git skins/Citizen; \
    fi

# Fix ownership for webserver user
RUN chown -R www-data:www-data extensions/ skins/ vendor/ config/ cache/

# Entrypoint + helper scripts
COPY --chmod=0755 scripts/*.sh /scripts/

ENV APACHE_DOCUMENT_ROOT=/var/www/html

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["/scripts/run-wiki.sh"]