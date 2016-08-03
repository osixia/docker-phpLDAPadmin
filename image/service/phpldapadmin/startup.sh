#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-phpldapadmin-first-start-done"

#
# HTTPS config
#
if [ "${PHPLDAPADMIN_HTTPS,,}" == "true" ]; then

  log-helper info "Set apache2 https config..."

  # generate a certificate and key if files don't exists
  # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
  ssl-helper ${PHPLDAPADMIN_SSL_HELPER_PREFIX} "${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CA_CRT_FILENAME"

  # add CA certificat config if CA cert exists
  if [ -e "${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CA_CRT_FILENAME" ]; then
    sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/https.conf
  fi

  ln -sf ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/https.conf /etc/apache2/sites-available/phpldapadmin.conf
#
# HTTP config
#
else
  log-helper info "Set apache2 http config..."
  ln -sf ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/apache2/http.conf /etc/apache2/sites-available/phpldapadmin.conf
fi

#
# Reverse proxy config
#
if [ "${PHPLDAPADMIN_TRUST_PROXY_SSL,,}" == "true" ]; then
  echo 'SetEnvIf X-Forwarded-Proto "^https$" HTTPS=on' > /etc/apache2/mods-enabled/remoteip_ssl.conf
fi

a2ensite phpldapadmin | log-helper debug

#
# phpLDAPadmin directory is empty, we use the bootstrap
#
if [ ! "$(ls -A /var/www/phpldapadmin)" ]; then

  log-helper info "Bootstap phpLDAPadmin..."

  cp -R /var/www/phpldapadmin_bootstrap/* /var/www/phpldapadmin
  rm -rf /var/www/phpldapadmin_bootstrap
  rm -f /var/www/phpldapadmin/config/config.php
fi

# if there is no config
if [ ! -e "/var/www/phpldapadmin/config/config.php" ]; then

  # on container first start customise the container config file
  if [ ! -e "$FIRST_START_DONE" ]; then

    get_salt() {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpLDAPadmin cookie secret
    get_salt
    sed -i "s|{{ PHPLDAPADMIN_CONFIG_BLOWFISH }}|${salt}|g" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config.php

    append_to_file() {
      TO_APPEND=$1
      sed -i "s|{{ PHPLDAPADMIN_SERVERS }}|${TO_APPEND}\n{{ PHPLDAPADMIN_SERVERS }}|g" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config.php
    }

    append_value_to_file() {
      local TO_PRINT=$1
      local VALUE=$2
      local php_value=$(print_by_php_type "$VALUE")
      append_to_file "\$servers->setValue($TO_PRINT$php_value);"
    }

    print_by_php_type() {
      if [ "$1" == "True" ]; then
        echo "true"
      elif [ "$1" == "False" ]; then
        echo "false"
      elif [[ "$1" == array\(\'* ]]; then
        echo "$1"
      else
        echo "'$1'"
      fi
    }

    # phpLDAPadmin host config
    host_info(){
      local to_print=$1

      for info in $(complex-bash-env iterate "$2")
      do
        if [ $(complex-bash-env isRow "${!info}") = true ]; then
          local key=$(complex-bash-env getRowKey "${!info}")
          local valueVarName=$(complex-bash-env getRowValueVarName "${!info}")

          if [ $(complex-bash-env isTable "${!valueVarName}") = true ] || [ $(complex-bash-env isRow "${!valueVarName}") = true ]; then
            host_info "$to_print'$key'," "${valueVarName}"
          else
            append_value_to_file "$to_print'$key'," "${!valueVarName}"
          fi
        fi
      done
    }

    # phpLDAPadmin config
    for host in $(complex-bash-env iterate PHPLDAPADMIN_LDAP_HOSTS)
    do

      append_to_file "\$servers->newServer('ldap_pla');"

      if [ $(complex-bash-env isRow "${!host}") = true ]; then
        hostname=$(complex-bash-env getRowKey "${!host}")
        info=$(complex-bash-env getRowValueVarName "${!host}")

        append_to_file "\$servers->setValue('server','name','$hostname');"
        append_to_file "\$servers->setValue('server','host','$hostname');"
        host_info "" "$info"

      else
        append_to_file "\$servers->setValue('server','name','${!host}');"
        append_to_file "\$servers->setValue('server','host','${!host}');"
      fi
    done

    sed -i "/{{ PHPLDAPADMIN_SERVERS }}/d" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config.php

    touch $FIRST_START_DONE
  fi

  log-helper debug "link ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config.php to /var/www/phpldapadmin/config/config.php"
  ln -sf ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config.php /var/www/phpldapadmin/config/config.php

fi

# fix file permission
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
chown www-data:www-data -R /var/www

# symlinks special (chown -R don't follow symlinks)
chown www-data:www-data /var/www/phpldapadmin/config/config.php
chmod 400 /var/www/phpldapadmin/config/config.php

exit 0
