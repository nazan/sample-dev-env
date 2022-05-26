FROM php:7.2.23-fpm-stretch

ARG UID
ARG GID

RUN apt-get update && apt-get install -y \
    libmcrypt-dev \
    mysql-client \
    libmagickwand-dev \
    libldb-dev \
    libldap2-dev \
    zlib1g-dev \
    git-core \
    libicu-dev \
    wget \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zip \
    yarn \
    libzip-dev \
    unzip --no-install-recommends \
    ghostscript \
    poppler-utils \
    libssl-dev \
    pdftk \
    chromium \
    procps \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

RUN docker-php-ext-configure intl \
    && docker-php-ext-install intl

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap
    
RUN docker-php-ext-install -j$(nproc) iconv

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip

RUN docker-php-ext-install exif

RUN docker-php-ext-install bcmath

RUN pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install pdo_mysql zip

RUN pecl install xdebug-2.6.0 \
    && docker-php-ext-enable xdebug

# Add mongo db support
RUN pecl install mongodb &&  echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongo.ini

ENV PHPREDIS_VERSION 5.3.4
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

RUN docker-php-ext-configure pcntl --enable-pcntl && docker-php-ext-install pcntl

RUN docker-php-ext-install sockets

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /usr/src/aidock/build/log && touch /usr/src/aidock/build/log/php-error.log && chmod 777 /usr/src/aidock/build/log/php-error.log

RUN mkdir -p /usr/src/aidock/build/share

RUN if grep -q "^appuser" /etc/group; then echo "Group already exists."; else groupadd -g $GID appuser; fi
RUN useradd -m -r -u $UID -g appuser appuser

# Install nvm with node and npm
RUN mkdir -p /usr/local/nvm

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.16.1

RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install --global cross-env

EXPOSE 22
RUN git config --global url."https://".insteadOf git://

RUN mkdir -p /usr/local/git-dummy
RUN git init /usr/local/git-dummy
ENV GIT_DIR /usr/local/git-dummy

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
