FROM osixia/web-baseimage:0.1.3
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# phpLDAPadmin version
ENV PHPLDAPADMIN_VERSION 1.2.3
ENV PHPLDAPADMIN_SHA1 669fca66c75e24137e106fdd02e3832f81146e23

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Install apache2 and php5-fpm using osixia/baseimage utils
# Caution: /container/tool/install-service-available arguments order is important
# php5-fpm install will detect apache2 and configure it

# Download, check integrity and unzip phpLDAPadmin to /var/www/phpldapadmin_bootstrap
RUN apt-get update \
		&& /container/tool/install-multiple-process-stack \
		&& /container/tool/install-service-available apache2 php5-fpm ssl-helper-openssl ssl-helper-gnutls \
		&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
			 patch \
			 php5-ldap \
			 php5-readline \
			 curl \
		&& curl -o phpldapadmin.tgz -SL http://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${PHPLDAPADMIN_VERSION}/phpldapadmin-${PHPLDAPADMIN_VERSION}.tgz \
		&& echo "$PHPLDAPADMIN_SHA1 *phpldapadmin.tgz" | sha1sum -c - \
		&& mkdir -p /var/www/phpldapadmin_bootstrap /var/www/phpldapadmin \
		&& tar -xzf phpldapadmin.tgz --strip 1 -C /var/www/phpldapadmin_bootstrap \
		&& apt-get remove -y --purge --auto-remove curl

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script and clean all
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service \
		&& rm phpldapadmin.tgz \
		&& apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /container/environment/env.yaml

# Set phpLDAPadmin data directory in a data volume
VOLUME ["/var/www/phpldapadmin"]

# Expose http and https default ports
EXPOSE 80 443
