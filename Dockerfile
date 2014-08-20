FROM osixia/baseimage:0.8.1
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Default configuration: can be overridden at the docker command line
ENV LDAP_HOST 127.0.0.1
ENV LDAP_BASE_DN dc=example,dc=com
ENV LDAP_LOGIN_DN cn=admin,dc=example,dc=com
ENV LDAP_SERVER_NAME docker.io phpLDAPadmin

# phpLDAPadmin SSL certificat and private key filename
ENV PHPLDAPADMIN_SSL_CRT_FILENAME phpldapadmin.crt
ENV PHPLDAPADMIN_SSL_KEY_FILENAME phpldapadmin.key

# LDAP CA certificat filename
ENV LDAP_TLS_CA_NAME ca.crt

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Enable php and nginx
RUN /sbin/enable-service php5-fpm nginx

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install phpLDAPadmin
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends phpldapadmin

# Expose http and https default ports
EXPOSE 80 443

# Create LDAP CA certificat directory
RUN mkdir /etc/ldap/ssl

# phpLDAPadmin config
RUN mkdir -p /etc/my_init.d
ADD service/phpldapadmin/phpldapadmin.sh /etc/my_init.d/phpldapadmin.sh

# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
