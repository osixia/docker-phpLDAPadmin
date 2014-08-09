FROM osixia/baseimage:0.6.0
MAINTAINER Jens Rabe <rabe-jens@t-online.de>

# Default configuration: can be overridden at the docker command line
ENV LDAP_HOST 127.0.0.1
ENV LDAP_BASE_DN dc=example,dc=com
ENV LDAP_LOGIN_DN cn=admin,dc=example,dc=com
ENV LDAP_SERVER_NAME docker.io phpLDAPadmin

# nginx SSL settings; Change these to suit your needs, or override using -e on docker run
ENV SSL_COUNTRY XX
ENV SSL_STATE Some-State
ENV SSL_LOCATION Some-Country
ENV SSL_ORGANIZATION Some-Organization
ENV SSL_COMMON_NAME Some-Common-Name

# TLS configs
# add to run command -v some/host/dir:/etc/ldap/ssl
# the directory some/host/dir must contain the ldap CA certificat file named ca.crt

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

# Expose ports 80 and 443 must (match port in phpLDAPadmin.nginx)
EXPOSE 80
EXPOSE 443

# Create SSL dir for nginx; will be populated on first run
RUN mkdir -p /etc/nginx/ssl

# Create TSL certificats directory
RUN mkdir /etc/ldap/ssl
# phpLDAPadmin config
RUN mkdir -p /etc/my_init.d
ADD service/phpldapadmin/phpldapadmin.sh /etc/my_init.d/phpldapadmin.sh

# Fix the bug with password_hash
# See http://stackoverflow.com/questions/20673186/getting-error-for-setting-password-feild-when-creating-generic-user-account-phpl
RUN sed -i "s/'password_hash'/'password_hash_custom'/" /usr/share/phpldapadmin/lib/TemplateRender.php

# Hide template warnings
RUN echo "<?php \$config->custom->appearance['hide_template_warning'] = true; ?>" >>/usr/share/phpldapadmin/config/config.php

# phpLDAPadmin nginx config
ADD service/phpldapadmin/config/phpldapadmin.nginx /etc/nginx/sites-available/phpldapadmin

# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
