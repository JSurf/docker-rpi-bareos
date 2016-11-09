FROM debian:jessie

RUN apt-get -q update
RUN apt-get -y -qq install wget
RUN echo deb http://download.bareos.org/bareos/release/16.2/Debian_8.0/ / > /etc/apt/sources.list.d/bareos.list
RUN wget -q http://download.bareos.org/bareos/release/16.2/Debian_8.0/Release.key -O- | apt-key add -
RUN apt-get -q update
RUN echo bareos-database-common bareos-database-common/dbconfig-install boolean false | debconf-set-selections
RUN echo bareos-database-common bareos-database-common/install-error select ignore | debconf-set-selections
RUN echo bareos-database-common bareos-database-common/database-type select mysql | debconf-set-selections
RUN echo bareos-database-common bareos-database-common/missing-db-package-error select ignore | debconf-set-selections
RUN echo postfix postfix/main_mailer_type select No configuration | debconf-set-selections
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y -qq install bareos bareos-database-mysql bareos-webui 
RUN apt-get -y install supervisor
RUN apt-get -y install mysql-client
#ENV ZF2_PATH="/usr/share/php/zend/library/"
ADD supervisord.conf /etc/supervisord.conf
ADD *.sh /
RUN chmod 755 *.sh
RUN cp /etc/bareos/bareos-dir.d/console/admin.conf.example /etc/bareos/bareos-dir.d/console/admin.conf
ADD MyCatalog.conf /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
