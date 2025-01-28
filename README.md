kivitendo_docker
================

Docker Build for Kivitendo 3.9.1 
 - debian:bookworm-slim
 - Kivitendo 3.9.1

The docker-compose file will use postgres 16.6 in addition. 

# Start the app locally

Start the app with docker-compose:
docker-compose up -d

Log into the app as an Admin (Password: admin_test)
http://localhost/kivitendo-erp/controller.pl?action=Admin/login

Setup the AUTH database and start to configure your first 
database | User | Mandant with "Vollzugriff"


# ToDo´s
- Import templates
- Configuration of Taskserver for auto startup  (currently manual start in the system tab needed)
- reducing the image size
- integrate CRM (from Kivitendo or via API)

# Special Thanks
shout out to rwunderer - his recent files https://github.com/rwunderer/kivitendo were brilliant!
