# Dockerfile for Sendportal service
FROM php:7.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Clone the Sendportal repository
RUN git clone --depth 1 --branch v2.0.0 https://github.com/mettle/sendportal.git .

# Copy .sendportal.env to .env in the container
COPY .sendportal.env .env

# Install PHP dependencies
RUN composer install

# Run Laravel installation
RUN php artisan sp:install

# Set up a cron job for Laravel scheduling
RUN echo "* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1" | crontab -

# Start the cron service and Apache
CMD cron && apache2-foreground
