#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Check if bench is installed
if ! command_exists bench; then
    echo "Bench is not installed. Please install bench before running this script."
    exit 1
fi

# Navigate to home directory
cd /home/frappe

# Check if bench already exists
if [ -d "/home/frappe/frappe-bench" ]; then
    echo "Bench already exists, proceeding to setup."
    cd frappe-bench
else
    echo "Creating new bench..."
    # Initialize bench without Redis
    bench init --skip-redis-config-generation frappe-bench --python python3
    cd frappe-bench
fi

# Set PostgreSQL and Redis configurations
bench set-config -g db_host postgres
bench set-config -g db_port 5432
bench set-config -g redis_cache redis://redis:6379
bench set-config -g redis_queue redis://redis:6379
bench set-config -g redis_socketio redis://redis:6379

# Remove Redis and watch processes from Procfile if they exist
sed -i '/redis/d' Procfile
sed -i '/watch/d' Procfile

# Get the LMS and CRM apps, use --overwrite to avoid prompts
bench get-app --resolve-deps --overwrite lms https://github.com/frappe/lms.git
bench get-app --resolve-deps --overwrite crm https://github.com/frappe/crm.git

# Install Node.js dependencies and build assets
bench setup requirements --node
bench setup requirements --dev
bench build --force

# Create the edu.gigapros.io site and install the LMS app
if bench --site edu.gigapros.io list-apps > /dev/null 2>&1; then
    echo "Site edu.gigapros.io already exists."
else
    bench new-site edu.gigapros.io \
        --force \
        --admin-password admin \
        --db-type postgres \
        --db-host postgres \
        --db-port 5432 \
        --db-name edu_gigapros_io \
        --db-root-username giga \
        --db-root-password giga \
        --no-mariadb-socket 

    bench --site edu.gigapros.io install-app lms
    bench --site edu.gigapros.io set-config developer_mode 1
    bench --site edu.gigapros.io clear-cache
fi

# Set the default site
bench use edu.gigapros.io

# Create the crm.gigapros.io site and install the CRM app
if bench --site crm.gigapros.io list-apps > /dev/null 2>&1; then
    echo "Site crm.gigapros.io already exists."
else
    bench new-site crm.gigapros.io \
        --force \
        --admin-password admin \
        --db-type postgres \
        --db-host postgres \
        --db-port 5432 \
        --db-name crm_gigapros_io \
        --db-root-username giga \
        --db-root-password giga \
        --no-mariadb-socket \

    bench --site crm.gigapros.io install-app crm
fi

# Start bench
bench start