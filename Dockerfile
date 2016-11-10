#FROM debian:jessie
FROM jsurf/rpi-raspbian:latest

ENV DEBIAN_FRONTEND noninteractive

#ENV BAREOS_REPO_URL "http://download.bareos.org/bareos/release/16.2/Debian_8.0/ /"
#ENV BAREOS_REPO_KEY http://download.bareos.org/bareos/release/16.2/Debian_8.0/Release.key
ENV BAREOS_REPO_URL "https://packagecloud.io/jsurf/raspbian/debian/ jessie main"
ENV BAREOS_REPO_KEY https://packagecloud.io/jsurf/raspbian/gpgkey

RUN [ "cross-build-start" ]

# Install Apache
RUN apt-get update && apt-get install -y apache2-bin apache2.2-common --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -ex \
	\
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	&& sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS" \
	\
# setup directories and permissions
	&& . "$APACHE_ENVVARS" \
	&& for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
		/var/www/html \
	; do \
		rm -rvf "$dir" \
		&& mkdir -p "$dir" \
		&& chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
	done

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# logs should go to stdout / stderr
RUN set -ex \
	&& . "$APACHE_ENVVARS" \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

# Install bareos
RUN apt-get update \ 
    && apt-get -y install wget apt-transport-https --no-install-recommends \
    && echo deb $BAREOS_REPO_URL > /etc/apt/sources.list.d/bareos.list \
    && wget -q $BAREOS_REPO_KEY -O- | apt-key add - \
    && apt-get update \
    && echo bareos-database-common bareos-database-common/dbconfig-install boolean false | debconf-set-selections \
    && echo bareos-database-common bareos-database-common/install-error select ignore | debconf-set-selections \
    && echo bareos-database-common bareos-database-common/database-type select mysql | debconf-set-selections \
    && echo bareos-database-common bareos-database-common/missing-db-package-error select ignore | debconf-set-selections \
    && echo postfix postfix/main_mailer_type select No configuration | debconf-set-selections \
    && apt-get -y install bareos bareos-database-mysql bareos-webui supervisor mysql-client --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install start scripts and configuration
ADD rootfs/ /

VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

EXPOSE 9101 9102 9103

RUN [ "cross-build-end" ]

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
