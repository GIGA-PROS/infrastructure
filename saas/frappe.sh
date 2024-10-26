#!/bin/bash

# Check if bench already exists

echo "Creating new bench..."

# Initialize bench without Redis
bench init --skip-redis-config-generation frappe-bench

cd frappe-bench

# Set PostgreSQL and Redis configurations
bench set-postgres-host postgres
bench set-redis-cache-host redis
bench set-redis-queue-host redis
bench set-redis-socketio-host redis

# Remove Redis and watch processes from Procfile
sed -i '/redis/d' Procfile
sed -i '/watch/d' Procfile

# Get the LMS and CRM apps
bench get-app lms
bench get-app crm

# Create the edu.gigapros.io site and install the LMS app
bench new-site edu.gigapros.io \
    --force \
    --admin-password admin \
    --db-type postgres \
    --db-host postgres \
    --db-port 5432 \
    --db-name edu_gigapros_io \
    --db-root-username giga \
    --db-root-password giga

bench --site edu.gigapros.io install-app lms
bench --site edu.gigapros.io set-config developer_mode 1
bench --site edu.gigapros.io clear-cache

# Create the crm.gigapros.io site and install the CRM app
bench new-site crm.gigapros.io \
    --force \
    --admin-password admin \
    --db-type postgres \
    --db-host postgres \
    --db-port 5432 \
    --db-name crm_gigapros_io \
    --db-root-username giga \
    --db-root-password giga

bench --site crm.gigapros.io install-app crm


# Start bench
bench start
