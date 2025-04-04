FROM webdevops/php-nginx:8.2-alpine

COPY . /var/www/html

WORKDIR /var/www/html

# Install dependencies
RUN apk add --no-cache composer && \
    composer install --no-dev --optimize-autoloader

# Laravel optimizations
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Environment variables
ENV PORT 8080
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr
ENV PHP_ERRORS_STDERR 1

EXPOSE $PORT

CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]