# Utilisez une image de base officielle de PHP avec FPM (FastCGI Process Manager)
FROM php:8.1-fpm

# Mettre à jour les paquets et installer les dépendances nécessaires pour PHP et les extensions requises
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Installer Node.js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Installer npm
RUN apt-get install -y npm

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail dans le conteneur
WORKDIR /var/www

# Copier les fichiers du projet dans le conteneur
COPY . /var/www

# Installer les dépendances de l'application Laravel avec Composer
RUN composer install --no-interaction

# Installer les dépendances npm et construire les assets (si nécessaire)
RUN npm install && npm run build

# Générer la clé d'application Laravel
RUN php artisan key:generate

# Exécuter les migrations de la base de données (Optionnel: commenter cette ligne si vous préférez exécuter les migrations manuellement)
# RUN php artisan migrate:fresh --seed

# Exposer le port 9000 sur lequel PHP-FPM écoute par défaut
EXPOSE 9000

# Démarrer PHP-FPM
CMD ["php-fpm"]
