# Stage 1: Build Stage
FROM debian:bookworm-slim AS build

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin

# Install only essential build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    perl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone Kivitendo source
ARG BUILD_KIVITENDO_VERSION="3.9.1"
RUN git clone --depth 1 --branch release-${BUILD_KIVITENDO_VERSION%-*} \
    https://github.com/kivitendo/kivitendo-erp.git /build/kivitendo-erp && \
    rm -rf /build/kivitendo-erp/.git

# Stage 2: Final Stage
FROM debian:bookworm-slim

ENV TZ=Europe/Berlin \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2

# Install only required runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-fcgid \
    postgresql-client \
    poppler-utils \
    # Perl dependencies
    libarchive-zip-perl \
    libclone-perl \
    libconfig-std-perl \
    libdatetime-perl \
    libdbd-pg-perl \
    libdbi-perl \
    libemail-address-perl \
    libemail-mime-perl \
    libfcgi-perl \
    libjson-perl \
    liblist-moreutils-perl \
    libnet-smtp-ssl-perl \
    libnet-sslglue-perl \
    libparams-validate-perl \
    libpdf-api2-perl \
    librose-db-object-perl \
    librose-db-perl \
    librose-object-perl \
    libsort-naturally-perl \
    libstring-shellquote-perl \
    libtemplate-perl \
    libtext-csv-xs-perl \
    libtext-iconv-perl \
    liburi-perl \
    libxml-writer-perl \
    libyaml-perl \
    libimage-info-perl \
    libgd-gd2-perl \
    libdatetime-event-cron-perl \
    libexception-class-perl \
    libfile-flock-perl \
    libdaemon-generic-perl \
    libencode-imaputf7-perl \
    libalgorithm-checkdigits-perl \
    libcgi-pm-perl \
    libfile-copy-recursive-perl \
    libfile-mimeinfo-perl \
    libhtml-restrict-perl \
    libimager-perl \
    libimager-qrcode-perl \
    libipc-run-perl \
    liblist-utilsby-perl \
    libmath-round-perl \
    libmail-imapclient-perl \
    libpbkdf2-tiny-perl \
    librest-client-perl \
    libuuid-tiny-perl \
    libdatetime-format-strptime-perl \
    && rm -rf /var/lib/apt/lists/*

# Copy app from build stage
COPY --from=build /build/kivitendo-erp /var/www/kivitendo-erp

# Verify and configure Kivitendo
# RUN cd /build/kivitendo-erp && perl scripts/installation_check.pl -v

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configure Apache and Kivitendo
COPY conf/apache-config.conf /etc/apache2/apache2.conf
COPY conf/apache-default.conf /etc/apache2/sites-available/000-default.conf
COPY conf/kivitendo.conf /var/www/kivitendo-erp/.config/kivitendo.conf

# Enable required Apache modules and disable unnecessary logs
RUN a2enmod cgi fcgid && a2disconf other-vhosts-access-log

# Create and configure directories
RUN mkdir -p \
    /var/run/apache2 \
    /var/lock/apache2 \
    /var/log/apache2 \
    /var/run/apache2/socks \
    /var/www/kivitendo-erp/{users,spool,webdav,config,templates} \
    /var/lib/kivitendo/{config,users} \
    && chown -R www-data:www-data \
        /var/run/apache2 \
        /var/lock/apache2 \
        /var/log/apache2 \
        /var/www/kivitendo-erp \
    && chmod -R 775 \
        /var/run/apache2 \
        /var/lock/apache2 \
        /var/log/apache2 \
        /var/www/kivitendo-erp



# Add custom startup scripts
COPY scripts/startKivi.sh scripts/startTaskserver.sh scripts/wait-for-postgres.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 8080

USER www-data
ENTRYPOINT ["/usr/local/bin/startKivi.sh"]