#!/bin/bash

sed -i "/admin_password/c\admin_password $ADMIN_PASSWORD" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/user     =/c\user     = $POSTGRES_USER" /var/www/kivitendo-erp/config/kivitendo.conf
sed -i "/password =/c\password = $POSTGRES_PASSWORD" /var/www/kivitendo-erp/config/kivitendo.conf


#host     = postgres_container
#port     = 5432
#db       = kivitendo_auth
#user     = postgres
#password = changeme

exec apache2 -DFOREGROUND