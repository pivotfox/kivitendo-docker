#!/bin/bash

sed -i "/admin_password = admin123/c\admin_password = $ADMIN_PASSWORD" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/user     = postgres/c\user     = $POSTGRES_USER" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/password = test/c\password = $POSTGRES_PASSWORD" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/host     = localhost/c\host     = $POSTGRES_HOST" /var/www/kivitendo-erp/config/kivitendo.conf

#sed -i "/TEXT_TO_BE_REPLACED/c $REPLACEMENT_TEXT_STRING" /tmp/foo
#sed -i '/TEXT_TO_BE_REPLACED/c\This line is removed by the admin.' /tmp/foo
# service kivitendo-task-server start

#systemctl daemon-reload
# systemctl enable kivitendo-task-server.service
# systemctl start kivitendo-task-server.service

# host     = postgres_container
# port     = 5432
# db       = kivitendo_auth
# user     = postgres
# password = changeme

exec apache2 -DFOREGROUND