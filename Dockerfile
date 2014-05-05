FROM phusion/baseimage
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.fr>

# Default configuration: can be overridden at the docker command line
ENV LDAP_HOST 127.0.0.1
ENV LDAP_BASE_DN dc=example,dc=com
ENV LDAP_LOGIN_DN cn=admin,dc=example,dc=com
ENV LDAP_SERVER_NAME docker.io phpLDAPadmin

# TLS configs
# if set to true add to run command -v some/host/dir:/etc/ldap/ssl
# and the directory some/host/dir must contain the ldap CA certificat file named ca.crt
ENV LDAP_TLS false

# Set correct environment variables
ENV HOME /root
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install php, phpLDAPadmin and nginx
RUN apt-get install -y php5-fpm php5-cli php5-ldap php-apc phpldapadmin nginx

# Expose port 80 must (match port in phpLDAPadmin.nginx)
EXPOSE 80

# Create TSL certificats directory
RUN mkdir /etc/ldap/ssl

# phpLDAPadmin nginx config
ADD phpLDAPadmin.nginx /etc/nginx/sites-available/phpLDAPadmin

# php5-fpm deamon
RUN mkdir /etc/service/php5-fpm
ADD php5-fpm.sh /etc/service/php5-fpm/run
RUN chmod +x /etc/service/php5-fpm/run

# phpLDAPadmin nginx deamon
RUN mkdir /etc/service/phpLDAPadmin
ADD phpLDAPadmin.sh /etc/service/phpLDAPadmin/run
RUN chmod +x /etc/service/phpLDAPadmin/run

# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
