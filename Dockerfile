FROM debian:jessie
#FROM jsurf/rpi-raspbian:latest

ENV DEBIAN_FRONTEND noninteractive

ENV BAREOS_REPO_URL "http://download.bareos.org/bareos/release/16.2/Debian_8.0/ /"
ENV BAREOS_REPO_KEY http://download.bareos.org/bareos/release/16.2/Debian_8.0/Release.key
#ENV BAREOS_REPO_URL "https://packagecloud.io/jsurf/raspbian/debian/ jessie main"
#ENV BAREOS_REPO_KEY https://packagecloud.io/jsurf/raspbian/gpgkey

#RUN [ "cross-build-start" ]

# Install Nginx and PHP
RUN apt-get update \
    && apt-get install -y nginx php5 php5-fpm --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

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
RUN chmod 755 *.sh
#VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

EXPOSE 9100 9101 9102 9103

#RUN [ "cross-build-end" ]

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
