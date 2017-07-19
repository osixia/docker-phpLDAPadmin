FROM osixia/web-baseimage:1.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# phpLDAPadmin version
ARG PHPLDAPADMIN_VERSION=1.2.3
ARG PHPLDAPADMIN_SHA1=669fca66c75e24137e106fdd02e3832f81146e23

# Add multiple process stack to supervise apache2 and php7.0-fpm
# sources: https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-multiple-process-stack
#          https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-service-available
#          https://github.com/osixia/docker-web-baseimage/blob/stable/image/service-available/:apache2/download.sh
#          https://github.com/osixia/docker-web-baseimage/blob/stable/image/service-available/:php7.0-fpm/download.sh
#          https://github.com/osixia/light-baseimage/blob/stable/image/service-available/:ssl-tools/download.sh
# Install ca-certificates, curl and php dependencies
# Download phpLDAPadmin, check file integrity, and unzip phpLDAPadmin to /var/www/phpldapadmin_bootstrap
# Remove curl
RUN apt-get update \
		&& /container/tool/add-multiple-process-stack \
		&& /container/tool/add-service-available :apache2 :php7.0-fpm :ssl-tools \
		&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		   ca-certificates \
			 curl \
			 patch \
			 php7.0-ldap \
			 php7.0-readline \
			 php7.0-xml \
		&& curl -o phpldapadmin.tgz -SL https://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${PHPLDAPADMIN_VERSION}/phpldapadmin-${PHPLDAPADMIN_VERSION}.tgz \
		&& echo "$PHPLDAPADMIN_SHA1 *phpldapadmin.tgz" | sha1sum -c - \
		&& mkdir -p /var/www/phpldapadmin_bootstrap /var/www/phpldapadmin \
		&& tar -xzf phpldapadmin.tgz --strip 1 -C /var/www/phpldapadmin_bootstrap \
		&& apt-get remove -y --purge --auto-remove curl ca-certificates \
		&& rm phpldapadmin.tgz \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

# Set phpLDAPadmin data directory in a data volume
VOLUME ["/var/www/phpldapadmin"]

# Expose http and https default ports
EXPOSE 80 443
