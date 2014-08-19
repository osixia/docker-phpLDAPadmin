#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

status () {
  echo "---> ${@}" >&2
}

getBaseDn () {
  IFS="."
  export IFS

  domain=$1
  init=1

  for s in $domain; do
    dc="dc=$s"
    if [ "$init" -eq 1 ]; then
      baseDn=$dc
      init=0
    else
      baseDn="$baseDn,$dc" 
    fi
  done
}

# a ldap container is linked to this phpLDAPadmin container
if [ -n "${LDAP_NAME}" ]; then
  LDAP_HOST=${LDAP_PORT_389_TCP_ADDR}
  
  # Get base dn from ldap domain
  getBaseDn ${LDAP_ENV_LDAP_DOMAIN}

  LDAP_BASE_DN=$baseDn
  LDAP_LOGIN_DN="cn=admin,$baseDn"
  LDAP_SERVER_NAME=${LDAP_ENV_LDAP_ORGANISATION}
else
  LDAP_HOST=${LDAP_HOST}
  LDAP_BASE_DN=${LDAP_BASE_DN}
  LDAP_LOGIN_DN=${LDAP_LOGIN_DN}
  LDAP_SERVER_NAME=${LDAP_SERVER_NAME}
fi

PHPLDAPADMIN_SSL_CRT_FILENAME=${PHPLDAPADMIN_SSL_CRT_FILENAME}
PHPLDAPADMIN_SSL_KEY_FILENAME=${PHPLDAPADMIN_SSL_KEY_FILENAME}

LDAP_TLS_CA_NAME=${LDAP_TLS_CA_NAME}

if [ ! -e /etc/phpldapadmin/docker_bootstrapped ]; then
  status "configuring LDAP for first run"

  if [ -e /etc/ldap/ssl/$LDAP_TLS_CA_NAME ]; then
    # LDAP  CA
    sed -i "s/TLS_CACERT.*/TLS_CACERT       \/etc\/ldap\/ssl\/ca.crt/g" /etc/ldap/ldap.conf
    sed -i '/TLS_CACERT/a\TLS_CIPHER_SUITE        HIGH:MEDIUM:+SSLv3' /etc/ldap/ldap.conf
    # phpLDAPadmin use tls
    sed -i "s/.*'server','tls'.*/\$servers->setValue('server','tls',true);/g" /etc/phpldapadmin/config.php
  fi

  # phpLDAPadmin config
  sed -i "s/'127.0.0.1'/'${LDAP_HOST}'/g" /etc/phpldapadmin/config.php
  sed -i "s/'dc=example,dc=com'/'${LDAP_BASE_DN}'/g" /etc/phpldapadmin/config.php
  sed -i "s/'cn=admin,dc=example,dc=com'/'${LDAP_LOGIN_DN}'/g" /etc/phpldapadmin/config.php
  sed -i "s/'My LDAP Server'/'${LDAP_SERVER_NAME}'/g" /etc/phpldapadmin/config.php

  # Fix the bug with password_hash
  # See http://stackoverflow.com/questions/20673186/getting-error-for-setting-password-feild-when-creating-generic-user-account-phpl
  sed -i "s/'password_hash'/'password_hash_custom'/" /usr/share/phpldapadmin/lib/TemplateRender.php

  # Hide template warnings
  sed -i "s:// \$config->custom->appearance\['hide_template_warning'\] = false;:\$config->custom->appearance\[\'hide_template_warning\'\] = true;:g" /etc/phpldapadmin/config.php

  # nginx config (tools from osixia/baseimage)
  /sbin/nginx-add-vhost localhost /usr/share/phpldapadmin/htdocs --php --ssl --ssl-crt=/etc/nginx/ssl/$PHPLDAPADMIN_SSL_CRT_FILENAME --ssl-key=/etc/nginx/ssl/$PHPLDAPADMIN_SSL_KEY_FILENAME
  /sbin/nginx-remove-vhost default

  touch /etc/phpldapadmin/docker_bootstrapped
else
  status "found already-configured phpLDAPadmin"
fi
