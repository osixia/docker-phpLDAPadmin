#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpldapadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpLDAPadmin vhost
  if [ "${HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-kit "/osixia/phpldapadmin/apache2/ssl/$SSL_CRT_FILENAME" "/osixia/phpldapadmin/apache2/ssl/$SSL_KEY_FILENAME"

    # add CA certificat config if CA cert exists
    if [ -e "/osixia/phpldapadmin/apache2/ssl/$SSL_CA_CRT_FILENAME" ]; then
      sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" /osixia/phpldapadmin/apache2/phpldapadmin-ssl.conf
    fi

    a2ensite phpldapadmin-ssl

  else
    a2ensite phpldapadmin
  fi

  get_salt () {
    salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:|{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
  }

  # phpLDAPadmin cookie secret
  get_salt
  sed -i "s/blowfish'] = '/blowfish'] = '${salt}/g" /osixia/phpldapadmin/config.php

  # Fix file permission
  find /var/www/ -type d -exec chmod 755 {} \;
  find /var/www/ -type f -exec chmod 644 {} \;
  chmod 400 /osixia/phpldapadmin/config.php
  chown www-data:www-data -R /osixia/phpldapadmin/config.php
  chown www-data:www-data -R /var/www

  touch $FIRST_START_DONE
fi

exit 0