#!/bin/bash

# Copy configuration files
cp -a /var/www/kivitendo-erp/.config/kivitendo.conf /var/www/kivitendo-erp/config/kivitendo.conf
#envsubst < /var/www/kivitendo-erp/.config/kivitendo.conf.in > /var/www/kivitendo-erp/config/kivitendo.conf

# Copy user files if .users directory exists
if [ -d "/var/www/kivitendo-erp/.users" ]; then
    cp -a /var/www/kivitendo-erp/.users/* /var/www/kivitendo-erp/users/
    cp -a /var/www/kivitendo-erp/.users/.??* /var/www/kivitendo-erp/users/
fi

# Create required directories
mkdir -p /tmp/socks
[ -d "${APACHE_RUN_DIR}" ] || mkdir -p ${APACHE_RUN_DIR}

# Wait for PostgreSQL to be ready
exec apache2 -DFOREGROUND
