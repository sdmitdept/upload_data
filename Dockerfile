FROM php:8.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libpng-dev libonig-dev libxml2-dev libzip-dev supervisor \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy composer files dulu (biar caching efektif)
COPY composer.json composer.lock ./

# Install dependencies (vendor)
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy project (kecuali yang ada di .dockerignore)
COPY . .

# Jalankan autoload dump setelah source dicopy
RUN composer dump-autoload --optimize

# Set permission storage, bootstrap, exports, dan logs
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chown -R www-data:www-data storage/app/exports \
    && chown -R www-data:www-data storage/logs \
    && chmod -R 775 storage/app/exports \
    && chmod -R 775 storage/logs

# Default command
CMD ["php-fpm"]
