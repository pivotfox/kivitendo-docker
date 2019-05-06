#!/bin/bash

sed -i "/admin_password/c\admin_password = $ADMIN_PASSWORD" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/user     =/c\user     = $POSTGRES_USER" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/password =/c\password = $POSTGRES_PASSWORD" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/host     =/c\host     = $HOST" /var/www/kivitendo-erp/config/kivitendo.conf

#service kivitendo-task-server start

systemctl daemon-reload
systemctl enable kivitendo-task-server.service
#systemctl start kivitendo-task-server.service

#host     = postgres_container
#port     = 5432
#db       = kivitendo_auth
#user     = postgres
#password = changeme

exec apache2 -DFOREGROUND