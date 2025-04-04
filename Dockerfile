FROM webdevops/php-nginx:8.2-alpine

COPY . /var/www/html
WORKDIR /var/www/html

# Instalar dependencias y configurar Laravel
RUN composer install --no-dev --optimize-autoloader \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Permisos para Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Variables de entorno para Render
ENV PORT 8080
ENV WEBROOT /var/www/html/public
ENV APP_ENV production
ENV APP_DEBUG false

# Configuración dinámica de Nginx para Render
RUN echo "server { \
    listen $PORT; \
    root $WEBROOT; \
    index index.php index.html; \
    location / { try_files \$uri \$uri/ /index.php?\$query_string; } \
    location ~ \.php$ { \
        fastcgi_pass 127.0.0.1:9000; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; \
    } \
}" > /etc/nginx/conf.d/default.conf

EXPOSE $PORT
CMD ["sh", "-c", "php-fpm && nginx -g 'daemon off;'"]