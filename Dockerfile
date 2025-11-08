# ============================================================
# Moodle GVA Base - Dockerfile (versió per a alumnes)
# Moodle 4.5 estable + tema Moove + config.php automàtic
# ============================================================

FROM php:8.3-apache

# --- Extensions i eines necessàries ---
RUN apt-get update && apt-get install -y \
    git unzip mariadb-client libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev libicu-dev libonig-dev libxslt1-dev \
    && docker-php-ext-install mysqli gd intl soap zip xsl bcmath opcache

# --- Apache ---
RUN a2enmod rewrite
RUN echo '<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/moodle.conf \
    && a2enconf moodle

# --- Configuració PHP ---
COPY php.ini /usr/local/etc/php/conf.d/php.ini

# --- Descarregar Moodle 4.5 estable ---
RUN git clone -b MOODLE_405_STABLE https://github.com/moodle/moodle.git /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# --- Instal·lar tema Moove ---
RUN cd /var/www/html/theme && \
    git clone https://github.com/willianmano/moodle-theme_moove.git moove && \
    chown -R www-data:www-data /var/www/html/theme/moove

# --- Copiar config.php base ---
COPY config.php /var/www/html/config.php
RUN chown www-data:www-data /var/www/html/config.php && chmod 640 /var/www/html/config.php

# --- Crear dades persistents ---
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 770 /var/www/moodledata

# --- 👇 AFEGIT: Idiomes + Upgrade automàtic + Purge ---
RUN apt-get install -y sudo && \
    sudo -u www-data php /var/www/html/admin/cli/langinstall.php ca es en || true && \
    sudo -u www-data php /var/www/html/admin/cli/upgrade.php --non-interactive --allow-unstable || true && \
    sudo -u www-data php /var/www/html/admin/cli/purge_caches.php || true

EXPOSE 80
CMD ["apache2-foreground"]

