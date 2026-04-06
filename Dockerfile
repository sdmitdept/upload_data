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

# Copy project
COPY . .

# Generate autoload
RUN composer dump-autoload --optimize

# ✅ FIX: pastikan semua folder ada dulu
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    storage/app/exports \
    bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Default command
CMD ["php-fpm"]