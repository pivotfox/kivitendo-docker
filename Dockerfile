FROM ubuntu:latest

MAINTAINER Marc Schickedanz <marc.schickedanz@pivotfox.de> version: 0.0.2

# parameter 
ARG BUILD_KIVITENDO_VERSION="release-3.5.4"
#ARG BUILD_TZ="Europe/Berlin"
ENV locale de_DE
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

#Packages
RUN apt-get -qq update && apt-get -y upgrade && apt-get install -y apache2 libarchive-zip-perl libclone-perl \
  libconfig-std-perl libdatetime-perl libdbd-pg-perl libdbi-perl \
  libemail-address-perl  libemail-mime-perl libfcgi-perl libjson-perl \
  liblist-moreutils-perl libnet-smtp-ssl-perl libnet-sslglue-perl \
  libparams-validate-perl libpdf-api2-perl librose-db-object-perl \
  librose-db-perl librose-object-perl libsort-naturally-perl \
  libstring-shellquote-perl libtemplate-perl libtext-csv-xs-perl \
  libtext-iconv-perl liburi-perl libxml-writer-perl libyaml-perl \
  libimage-info-perl libgd-gd2-perl libapache2-mod-fcgid \
  libfile-copy-recursive-perl libalgorithm-checkdigits-perl \
  libcrypt-pbkdf2-perl git libcgi-pm-perl libtext-unidecode-perl libwww-perl\
  postgresql-contrib aqbanking-tools poppler-utils libhtml-restrict-perl\
  libdatetime-set-perl libset-infinite-perl liblist-utilsby-perl\
  libdaemon-generic-perl libfile-flock-perl libfile-slurp-perl\
  libfile-mimeinfo-perl libpbkdf2-tiny-perl libregexp-ipv6-perl \
  libdatetime-event-cron-perl libexception-class-perl && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
#RUN echo "$BUILD_TZ" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

#ADD KIVITENDO
RUN git clone https://github.com/kivitendo/kivitendo-erp.git /var/www/kivitendo-erp
RUN cd /var/www/kivitendo-erp && git checkout ${BUILD_KIVITENDO_VERSION}
ADD /conf/kivitendo.conf /var/www/kivitendo-erp/config/kivitendo.conf

#Configure the taskserver
#scripts/boot/upstart/kivitendo-task-server.conf nach /etc/init/kivitendo-task-server.conf
#ADD /conf/kivitendo-task-server.service /etc/init/kivitendo-erp/config/kivitendo.conf
#RUN service kivitendo-task-server start

#Check Kivitendo installation
RUN cd /var/www/kivitendo-erp/ && perl /var/www/kivitendo-erp/scripts/installation_check.pl

# Setup APACHE as ``root`` user
USER root
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd

# Update the default apache site with the config 
COPY /conf/apache-config.conf /etc/apache2/apache2.conf

# SET Servername to localhost
RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf && a2enconf servername

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www
 
RUN chown -R www-data:www-data /var/www && chmod u+rwx,g+rx,o+rx /var/www && find /var/www -type d -exec chmod u+rwx,g+rx,o+rx {} + && find /var/www -type f -exec chmod u+rw,g+rw,o+r {} +

#Kivitendo rights
RUN mkdir /var/www/kivitendo-erp/webdav
RUN chown -R www-data /var/www/kivitendo-erp/users /var/www/kivitendo-erp/spool /var/www/kivitendo-erp/webdav
RUN chown www-data /var/www/kivitendo-erp/templates /var/www/kivitendo-erp/users
RUN chmod -R +x /var/www/kivitendo-erp/

#Perl Modul im Apache laden
RUN a2enmod cgi.load
RUN a2enmod fcgid.load

#set Port
EXPOSE 80

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/var/log/apache2", "/home", "/var/www/kivitendo-erp/users", "/var/www/kivitendo-erp/webdav", "/var/www/kivitendo-erp/templates", "/var/www/kivitendo-erp/config"]
#VOLUME  ["/var/log/apache2", "/home"]
# update kivi config and start apache
COPY /scripts/startKivi.sh /tmp/startKivi.sh
RUN chmod +x /tmp/startKivi.sh
ENTRYPOINT ["/tmp/startKivi.sh"]

