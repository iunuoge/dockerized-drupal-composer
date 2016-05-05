FROM drupal:8

ENV COMPOSER_SETUP_SHA384 a52be7b8724e47499b039d53415953cc3d5b459b9d9c0308301f867921c19efc623b81dfef8fc2be194a5cf56945d223
ENV DOCKERIZE_VERSION 0.2.0
ENV DOCKERIZE_SHA1 29be833b6e27009216da54114c4b47ee2534db8c

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEFAULT_TIMEZONE=Australia/Melbourne

RUN set -xe && \
    apt-get -qq update && \
    apt-get -qq install \
        git \
        zlib1g-dev \
        rsync \
        --no-install-recommends \
        && \
    docker-php-ext-install zip && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    curl -sS -o /tmp/composer-setup.php https://getcomposer.org/installer && \
    echo "$COMPOSER_SETUP_SHA384 */tmp/composer-setup.php" | shasum -c - && \
    php /tmp/composer-setup.php --install-dir=/usr/bin --filename=composer && \
    rm /tmp/composer-setup.php && \
    curl -L -o /tmp/dockerize.tar.gz \
        https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v0.2.0.tar.gz && \
    echo "$DOCKERIZE_SHA1 */tmp/dockerize.tar.gz" | sha1sum -c - && \
    tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz && \
    rm /tmp/dockerize.tar.gz && \
    curl -o /usr/local/bin/drush http://files.drush.org/drush.phar && \
    chmod +x /usr/local/bin/drush && \
    { \
        echo 'date.timezone = ${DEFAULT_TIMEZONE}'; \
    } > /usr/local/etc/php/conf.d/date-timezone.ini && \
    true

WORKDIR /app

COPY sites /var/www/html/sites
COPY composer.json composer.lock complete-install.sh /app/

RUN set -xe && \
    composer install --no-dev && \
    composer clear-cache && \
    true