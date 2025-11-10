# ============================================================
# Moodle GVA Base - Dockerfile (versió optimitzada i fusionada)
# Moodle 4.5 estable + tema Moove + idiomes + config.php automàtic
# ============================================================

FROM php:8.3-apache

# --- Extensions i eines necessàries ---
RUN apt-get update && apt-get install -y \
    git unzip mariadb-client libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev libicu-dev libonig-dev libxslt1-dev curl sudo \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli gd intl soap zip xsl bcmath opcache \
    && a2enmod rewrite headers expires ssl

# --- Configuració d’Apache per permetre .htaccess ---
RUN cat <<'EOF' > /etc/apache2/conf-available/moodle.conf
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
RUN a2enconf moodle || true
# --- Configuració PHP personalitzada ---
COPY php.ini /usr/local/etc/php/conf.d/php.ini

# --- Descarregar Moodle 4.5 estable ---
RUN git clone -b MOODLE_405_STABLE https://github.com/moodle/moodle.git /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# --- Instal·lar tema Moove ---
RUN cd /var/www/html/theme && \
    git clone https://github.com/willianmano/moodle-theme_moove.git moove && \
    chown -R www-data:www-data /var/www/html/theme/moove
# --- Correcció de dependències del tema Moove per Moodle 4.5.x ---
RUN cat > /var/www/html/theme/moove/version.php <<'EOF'
<?php
defined('MOODLE_INTERNAL') || die();
$plugin->version   = 2025092600;
$plugin->requires  = 2024000000;
$plugin->component = 'theme_moove';
$plugin->dependencies = [
    'theme_boost' => 2024100700
];
EOF

# --- Garantir que el tema Boost existeix (per compatibilitat amb Moove) ---
RUN cd /var/www/html/theme && \
    rm -rf boost && \
    git clone -b MOODLE_405_STABLE https://github.com/moodle/moodle.git tmp && \
    cp -r tmp/theme/boost . && \
    rm -rf tmp && \
    chown -R www-data:www-data /var/www/html/theme/boost

# --- Copiar config.php base ---
COPY config.php /var/www/html/config.php
RUN chown www-data:www-data /var/www/html/config.php && chmod 640 /var/www/html/config.php

# --- Crear dades persistents ---
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 770 /var/www/moodledata

# --- Idiomes i neteja inicial ---
RUN cd /var/www/html && \
    php admin/cli/langinstall.php ca_valencia es en || true && \
    php admin/cli/purge_caches.php || true && \
    chown -R www-data:www-data /var/www/html /var/www/moodledata

# --- Upgrade automàtic i neteja ---
RUN sudo -u www-data php /var/www/html/admin/cli/upgrade.php --non-interactive --allow-unstable || true && \
    sudo -u www-data php /var/www/html/admin/cli/purge_caches.php || true

# --- Eliminar plugin 'auleslook' si està registrat però no té fitxers ---
RUN sudo -u www-data php /var/www/html/admin/cli/uninstall.php --name=local_auleslook --non-interactive || true

EXPOSE 80
CMD ["apache2-foreground"]
