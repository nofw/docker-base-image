FROM php:7.1-apache

WORKDIR /var/www

ENV COMPOSER_VERSION=1.4.1 COMPOSER_PATH=/usr/local/bin COMPOSER_HOME=/composer COMPOSER_ALLOW_SUPERUSER=1

# Install dependencies and composer
RUN set -xe \
    && apt-get update && apt-get install -y \
        git \
        zlib1g-dev \
        libicu-dev \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-install -j$(nproc) intl gettext zip \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=${COMPOSER_PATH} --filename=composer --version=${COMPOSER_VERSION} \
    && mkdir -p $COMPOSER_HOME \
    && composer global require --quiet "hirak/prestissimo:^0.3"

# Configure Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN set -xe \
    && a2enmod rewrite \
    && rm -rf /var/www/html
