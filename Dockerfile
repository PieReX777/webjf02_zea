FROM webdevops/php-nginx:8.2-alpine

# Copia los archivos de tu proyecto
COPY . /var/www/html
WORKDIR /var/www/html

# Instala dependencias de sistema y PHP
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-pdo \
    php82-pdo_mysql \
    php82-opcache \
    php82-mbstring \
    php82-tokenizer \
    php82-xml

# Instala Composer y dependencias de Laravel
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --optimize-autoloader

# Configura Laravel (caché)
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Permisos para Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Puerto dinámico para Render
ENV PORT 8080
EXPOSE $PORT

# Configuración de Nginx para Render
RUN echo "server { \
    listen $PORT; \
    root /var/www/html/public; \
    index index.php index.html; \
    location / { \
        try_files \$uri \$uri/ /index.php?\$query_string; \
    } \
    location ~ \.php$ { \
        fastcgi_pass 127.0.0.1:9000; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; \
    } \
}" > /opt/docker/etc/nginx/vhost.conf

# Inicia PHP-FPM y Nginx
CMD ["sh", "-c", "php-fpm82 && nginx -g 'daemon off;'"]