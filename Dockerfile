FROM alpine:edge
RUN apk add bareos bareos-webui bareos-webui-apache2 --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted
RUN apk add supervisor mysql-client
RUN mkdir /run/apache2
RUN sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/apache2/httpd.conf
ENV ZF2_PATH="/usr/share/php/zend/library/"
COPY supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
