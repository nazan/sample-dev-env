FROM php:7.1.33-apache-stretch

ARG UID
ARG GID

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN mkdir -p /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get update && apt-get install --no-install-recommends --yes git unzip libpng-dev libzip-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libssl-dev

RUN git config --global url."https://".insteadOf git://

RUN docker-php-ext-install bcmath

RUN docker-php-ext-install pdo_mysql

RUN docker-php-ext-configure zip --with-libzip && docker-php-ext-install zip

RUN docker-php-ext-install exif

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

RUN docker-php-ext-configure intl && docker-php-ext-install intl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN mkdir -p /usr/src/aidock/build/log && touch /usr/src/aidock/build/log/php-error.log && chmod 777 /usr/src/aidock/build/log/php-error.log
RUN mkdir -p /usr/src/aidock/build/share

RUN if grep -q "^appuser" /etc/group; then echo "Group already exists."; else groupadd -g $GID appuser; fi
RUN useradd -m -r -u $UID -g appuser appuser

RUN mkdir -p /var/www/html/storage/app/bundles && chmod -R 777 /var/www/html/storage/app/bundles