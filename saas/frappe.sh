#!bin/bash

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
fi

export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

bench init --skip-redis-config-generation frappe-bench

cd frappe-bench

# Use containers instead of localhost
# bench set-mariadb-host mariadb
bench set-postgres-host postgres
bench set-redis-cache-host redis:6379
bench set-redis-queue-host redis:6379
bench set-redis-socketio-host redis:6379

# Remove redis, watch from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

bench get-app lms
bench get-app crm

# bench new-site edu.gigapros.io \
# --force \
# --mariadb-root-password 123 \
# --admin-password admin \
# --no-mariadb-socket

bench new-site edu.gigapros.io \
    --force \
    --admin-password admin \
    --db-root-username postgres \
    --db-root-password postgres \
    --db-type postgres \

bench --site edu.gigapros.io install-app lms
bench --site edu.gigapros.io set-config developer_mode 1
bench --site edu.gigapros.io clear-cache
bench --site crm.gigapros.io install-app crm

bench use edu.gigapros.io
bench use crm.gigapros.io

bench start