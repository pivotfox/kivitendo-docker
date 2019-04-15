experimental kivitendo_docker
================

Docker Build for Kivitendo a erp solution for small businesses.
 - Ubuntu:14.04
 - Postgresql 9.3
 - Kivitendo 3.5.2
 - Midnight Commander
 - phppgadmin



# Start the app

Browser: http://"ipadress":"port"/kivitendo-erp/



# ToDo´s
- Export old DB: PGPASSWORD="docker" pg_dumpall -h localhost -U docker > dump.sql
- Import old DB: psql -h localhost -U docker < dump.sql
- Import templates & webdav Files
- chown -R www-data templates webdav
- Configuration of Taskserver for autostartup  (see manual)
- Adaptation kivitendo-config (/var/www/kivitendo-erp/config/...)
