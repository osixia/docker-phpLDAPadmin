#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
# -u Treat unset variables as an error when substituting
set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: LDAP_HOST=${LDAP_HOST}
: PHPLDAPADMIN_BASE_DN=${PHPLDAPADMIN_BASE_DN}
: PHPLDAPADMIN_LOGIN_DN=${PHPLDAPADMIN_LOGIN_DN}
: PHPLDAPADMIN_SERVER_NAME=${PHPLDAPADMIN_SERVER_NAME}

if [ ! -e /etc/phpldapadmin/docker_bootstrapped ]; then
  status "configuring phpLDAPadmin for first run"

  # phpLDAPadmin config
  sed -i "s/'127.0.0.1'/'${LDAP_HOST}'/" /etc/phpldapadmin/config.php
  sed -i "s/'dc=example,dc=com'/'${PHPLDAPADMIN_BASE_DN}'/" /etc/phpldapadmin/config.php
  sed -i "s/'cn=admin,dc=example,dc=com'/'${PHPLDAPADMIN_LOGIN_DN}'/" /etc/phpldapadmin/config.php
  sed -i "s/'My LDAP Server'/'${PHPLDAPADMIN_SERVER_NAME}'/" /etc/phpldapadmin/config.php

  # nginx config
  ln -s /etc/nginx/sites-available/phpLDAPadmin /etc/nginx/sites-enabled/phpLDAPadmin
  rm /etc/nginx/sites-enabled/default
  echo "daemon off;" >> /etc/nginx/nginx.conf

  touch /etc/phpldapadmin/docker_bootstrapped
else
  status "found already-configured phpLDAPadmin"
fi

status "starting phpLDAPadmin"
set -x
exec service nginx start
