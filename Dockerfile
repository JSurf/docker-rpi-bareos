FROM jsurf/rpi-alpine
RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --no-cache add bareos@testing bareos-webui-apache2@testing supervisor

EXPOSE 80
RUN mkdir -p /run/apache2

COPY supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
 