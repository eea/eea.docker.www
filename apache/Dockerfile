FROM eeacms/httpd:centos7
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

RUN \
  yum -y updateinfo && \
  yum -y install \
    mod_ldap \
    mod_session \
    mod_ssl

#
# Cleanup
#
RUN yum clean all
