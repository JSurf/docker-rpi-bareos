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
RUN apt-get -y -qq install bareos
RUN apt-get -y -qq install bareos-database-mysql
#RUN apk add bareos bareos-webui bareos-webui-apache2 --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted
#RUN apk add supervisor mysql-client
#RUN mkdir /run/apache2
#RUN sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/apache2/httpd.conf \
#    && sed -ri \
#		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
#		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
#		"/etc/apache2/httpd.conf"
#ENV ZF2_PATH="/usr/share/php/zend/library/"
ADD supervisord.conf /etc/supervisord.conf
ADD *.sh /
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
