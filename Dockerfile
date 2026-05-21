# syntax=docker/dockerfile:1.7

# =============================================================================
# Arborisis — Dockerfile Production
# Multi-stage build optimisé : PHP 8.4-FPM Alpine + Node.js 22 Alpine
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1 : PHP Base
# Extensions et dépendances système communes
# -----------------------------------------------------------------------------
FROM php:8.4-fpm-alpine AS php-base

WORKDIR /var/www/html

# Dépendances système
RUN apk add --no-cache \
    ca-certificates \
    curl \
    ffmpeg \
    freetype-dev \
    git \
    icu-dev \
    jpeg-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    unzip \
    # GD dependencies
    libjpeg-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_pgsql \
        sockets \
        zip \
    && pecl install redis \
    && docker-php-ext-enable redis

# Créer l'utilisateur www-data s'il n'existe pas (Alpine)
RUN set -eux; \
    addgroup -g 82 -S www-data 2>/dev/null || true; \
    adduser -u 82 -D -S -G www-data www-data 2>/dev/null || true

# -----------------------------------------------------------------------------
# Stage 2 : Composer Dependencies
# Installation des packages PHP (production only)
# -----------------------------------------------------------------------------
FROM php-base AS composer-deps

WORKDIR /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY arborisis/composer.json arborisis/composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --no-scripts \
    --optimize-autoloader \
    --no-cache

# -----------------------------------------------------------------------------
# Stage 3 : Frontend Build
# Build Vite des assets (nécessite vendor/ pour ziggy)
# -----------------------------------------------------------------------------
FROM node:22-alpine AS assets

WORKDIR /app

COPY arborisis/package.json arborisis/package-lock.json ./
RUN npm ci --ignore-scripts

# Copie du code source + vendor (ziggy a besoin du vendor)
COPY arborisis/ .
COPY --from=composer-deps /app/vendor ./vendor

RUN npm run build

# -----------------------------------------------------------------------------
# Stage 4 : Production Runtime
# Image finale minimale
# -----------------------------------------------------------------------------
FROM php-base AS production

WORKDIR /var/www/html

# Configurations PHP
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/php/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-arborisis.ini

# Copie du code source
COPY arborisis/ .

# Copie des dépendances PHP (production)
COPY --from=composer-deps /app/vendor ./vendor

# Copie des assets buildés
COPY --from=assets /app/public/build ./public/build
COPY --from=assets /app/bootstrap/ssr ./bootstrap/ssr
COPY --from=assets /app/public/sw.js ./public/sw.js

# Permissions et stockage
RUN mkdir -p \
    storage/app \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/testing \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && cp -a public public.dist \
    && chown -R www-data:www-data storage bootstrap/cache public public.dist \
    && chmod -R 775 storage bootstrap/cache

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD php-fpm -t || exit 1

# Entrypoints
COPY docker/entrypoint.sh /usr/local/bin/arborisis-entrypoint
COPY docker/entrypoint-queue.sh /usr/local/bin/arborisis-entrypoint-queue
COPY docker/entrypoint-scheduler.sh /usr/local/bin/arborisis-entrypoint-scheduler
RUN chmod +x /usr/local/bin/arborisis-entrypoint \
    /usr/local/bin/arborisis-entrypoint-queue \
    /usr/local/bin/arborisis-entrypoint-scheduler

ENTRYPOINT ["arborisis-entrypoint"]
CMD ["php-fpm"]

EXPOSE 9000
