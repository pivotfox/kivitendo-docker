FROM ubuntu:14.04

# Inspired by drnoa/kivitendo_docker 

MAINTAINER Marc Schickedanz <marc.schickedanz@pivotfox.de> version: 0.0.2

#15.04.2019 Kivitendo 3.5.3

# parameter 
ARG BUILD_KIVITENDO_VERSION="release-3.5.3"
ARG BUILD_TZ="Europe/Berlin"
ENV locale de_DE

# set timezone
RUN echo "$BUILD_TZ" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

#Packages basic preparation
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && apt-get -y upgrade &&\
    apt-get -y install apache2 libarchive-zip-perl libclone-perl \
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
    language-pack-de-base sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
#Install Perl Modules
RUN cpan Path::Tiny File:Basedir File::DesktopEntry DateTime::event::Cron DateTime::Set \
         FCGI HTML::Restrict Image::Info PBKDF2::Tiny Text::Unidecode \
         Set::Infinite Rose::Db::Object HTML::Restrict Image::Info \
         Algorithm::CheckDigits PBKDF2::Tiny CGI File::MimeInfo Text::Unidecode \
         Thread::Pool::Simple LWP::Authen::Digest LWP::UserAgent cpan Set::Crontab

# ADD KIVITENDO
RUN git clone https://github.com/kivitendo/kivitendo-erp.git /var/www/kivitendo-erp
RUN cd /var/www/kivitendo-erp && git checkout release-3.5.3
ADD /conf/kivitendo.conf /var/www/kivitendo-erp/config/kivitendo.conf

#Check Kivitendo installation
RUN cd /var/www/kivitendo-erp/ && perl /var/www/kivitendo-erp/scripts/installation_check.pl

# Setup APACHE as ``root`` user
USER root

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd

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