FROM php:8.4-fpm-alpine

# Build deps + extensions
RUN set -eux; \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers; \
    pecl install xdebug; \
    docker-php-ext-install pdo_mysql; \
    apk del .build-deps; \
    rm -rf /tmp/pear
