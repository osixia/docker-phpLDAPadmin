FROM osixia/light-baseimage:0.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# phpLDAPadmin version
ENV PHPLDAPADMIN_VERSION 1.2.3
ENV PHPLDAPADMIN_SHA1 669fca66c75e24137e106fdd02e3832f81146e23

# Use baseimage-docker's init system.
CMD ["/osixia/tool/run"]

# Install apache2 and php5-fpm using osixia/baseimage utils
# Caution: /sbin/enable-service arguments order is important
# php5-fpm install will detect apache2 and configure it

# Download, check integrity and unzip phpLDAPadmin to /var/www/phpldapadmin_bootstrap
RUN apt-get update && /sbin/install-multiple-process-stack \
	&& /sbin/install-service-available apache2 php5-fpm ssl-helper-openssl ssl-helper-gnutls \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends patch php5-ldap php5-readline \
	&& curl -o phpldapadmin.tgz -SL http://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${PHPLDAPADMIN_VERSION}/phpldapadmin-${PHPLDAPADMIN_VERSION}.tgz \
	&& echo "$PHPLDAPADMIN_SHA1 *phpldapadmin.tgz" | sha1sum -c - \
	&& mkdir -p /var/www/phpldapadmin_bootstrap /var/www/phpldapadmin \
	&& tar -xzf phpldapadmin.tgz --strip 1 -C /var/www/phpldapadmin_bootstrap

# Add service directory to /osixia/service
ADD service /osixia/service

# Use baseimage install-service script and clean all
RUN ./sbin/install-service \
	&& rm phpldapadmin.tgz \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /etc/env.yaml

# Set phpLDAPadmin data directory in a data volume
VOLUME ["/var/www/phpldapadmin"]

# Expose http and https default ports
EXPOSE 80 443
