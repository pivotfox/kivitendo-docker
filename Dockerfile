FROM ubuntu:18.04

MAINTAINER Marc Schickedanz <marc.schickedanz@pivotfox.de> version: 0.0.4

#05.05.2019 Kivitendo 3.5.3

# parameter 
#ARG BUILD_KIVITENDO_VERSION="release-3.5.3"
ENV locale de_DE
ENV TZ 'Europe/Berlin'

#Packages basic preparation

# Set timezone in tzdata
RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

#Packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && apt-get -y upgrade &&\
    apt-get -y install \
    apache2 libarchive-zip-perl libclone-perl \
    libconfig-std-perl libdatetime-perl libdbd-pg-perl libdbi-perl \
    libemail-address-perl  libemail-mime-perl libfcgi-perl libjson-perl \
    liblist-moreutils-perl libnet-smtp-ssl-perl libnet-sslglue-perl \
    libparams-validate-perl libpdf-api2-perl librose-db-object-perl \
    librose-db-perl librose-object-perl libsort-naturally-perl libpq5 \
    libstring-shellquote-perl libtemplate-perl libtext-csv-xs-perl \
    libtext-iconv-perl liburi-perl libxml-writer-perl libyaml-perl \
    libimage-info-perl libgd-gd2-perl libapache2-mod-fcgid \
    libfile-copy-recursive-perl libalgorithm-checkdigits-perl \
    libcrypt-pbkdf2-perl git libcgi-pm-perl build-essential \
    sed aqbanking-tools poppler-utils libfile-mimeinfo-perl \
    libtext-unidecode-perl texlive-base-bin texlive-latex-recommended \
    texlive-fonts-recommended texlive-latex-extra texlive-lang-german \
    texlive-generic-extra libdaemon-generic-perl libdatetime-event-cron-perl \
    libset-crontab-perl libdatetime-set-perl libfile-flock-perl libfile-slurp-perl \
    liblist-utilsby-perl libregexp-ipv6-perl libset-infinite-perl \
    language-pack-de-base libwww-perl libhtml-restrict-perl libpbkdf2-tiny-perl \
    sudo systemd && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
 RUN cpan Set::Crontab

# apt install supervisor
# ADD supervisor to run kivi & taskserver
#ADD /conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ADD KIVITENDO
RUN git clone https://github.com/kivitendo/kivitendo-erp.git /var/www/kivitendo-erp
RUN cd /var/www/kivitendo-erp && git checkout release-3.5.3
ADD /conf/kivitendo.conf /var/www/kivitendo-erp/config/kivitendo.conf

# ADD Kivitendo Task Server Script 
ADD /conf/kivitendo-task-server.service /etc/systemd/system/kivitendo-task-server.service

#Check Kivitendo installation
RUN cd /var/www/kivitendo-erp/ && perl /var/www/kivitendo-erp/scripts/installation_check.pl

# Setup APACHE as ``root`` user
USER root

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# Update the default apache site with the config 
COPY /conf/apache-config.conf /etc/apache2/apache2.conf

# SET Servername to localhost
RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

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
 
RUN chown -R www-data:www-data /var/www
RUN chmod u+rwx,g+rx,o+rx /var/www
RUN find /var/www -type d -exec chmod u+rwx,g+rx,o+rx {} +
RUN find /var/www -type f -exec chmod u+rw,g+rw,o+r {} +

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
VOLUME  ["/var/log/apache2", "/var/www/kivitendo-erp/users", "/var/www/kivitendo-erp/webdav", "/var/www/kivitendo-erp/templates", "/var/www/kivitendo-erp/config", "/home"]

# update kivi config and start apache
COPY /scripts/startKivi.sh /tmp/startKivi.sh
RUN chmod +x /tmp/startKivi.sh
ENTRYPOINT ["/tmp/startKivi.sh"]