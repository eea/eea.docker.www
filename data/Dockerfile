FROM busybox
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

ENV APACHE_LOGS /var/local/www-logs/eea
RUN mkdir -p $APACHE_LOGS
RUN chown -R 1000:1000 $APACHE_LOGS
VOLUME $APACHE_LOGS

ENV APACHE_STATIC /var/www-static-resources
RUN mkdir -p $APACHE_STATIC
RUN chown -R 1000:1000 $APACHE_STATIC
VOLUME $APACHE_STATIC

USER 1000
