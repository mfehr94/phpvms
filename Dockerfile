FROM php:8.0.9-fpm-alpine3.14

WORKDIR /var/www/

# Setup composer
COPY --from=composer:2.1.5 /usr/bin/composer /usr/local/bin/composer

RUN apk add gmp-dev icu-dev zlib-dev libpng-dev libzip-dev zip
RUN curl --silent --show-error https://getcomposer.org/installer | php

# Copy any config files in
COPY resources/docker/php/ext-opcache.ini $PHP_INI_DIR/conf.d/
COPY resources/docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN ln -sf /dev/stderr /var/log/fpm-error.log

RUN docker-php-ext-install \
  calendar \
  intl \
  pdo_mysql \
  gd \
  gmp \
  bcmath \
  opcache \
  zip && \
  docker-php-ext-enable pdo_mysql opcache bcmath zip

COPY . /var/www/
RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

#RUN chown -R www-data:www-data /var/www

EXPOSE 9000
