# Dockerfile for Sendportal service
FROM php:8.2.25-cli-alpine3.20

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    cron \
    openssl \
    php-bcmath \
    php-curl \
    php-json \
    php-mbstring \
    php-mysql \
    php-tokenizer \ 
    php-xml \
    php-zip \
    php-pgsql

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

# DB_SSLMODE=prefer # add this to the .env??

RUN php artisan migrate --verbose

# Run Laravel installation
RUN php artisan sp:install

RUN php artisan key:generate

RUN php artisan vendor:publish --provider=Sendportal\\Base\\SendportalBaseServiceProvider
# crontab -e
# * * * * * cd /home/ubuntu/sendportal && php artisan schedule:run >> /dev/null 2>&1


# Set up a cron job for Laravel scheduling
RUN echo "* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1" | crontab -

# Start the cron service and Apache
CMD cron && apache2-foreground
