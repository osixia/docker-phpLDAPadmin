#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpldapadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpLDAPadmin vhost
  if [ "${PHPLDAPADMIN_HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    cfssl-helper phpldapadmin "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CRT_FILENAME" "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_KEY_FILENAME" "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CA_CRT_FILENAME"

    # add CA certificat config if CA cert exists
    if [ -e "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CA_CRT_FILENAME" ]; then
      sed -i --follow-symlinks "s/#SSLCACertificateFile/SSLCACertificateFile/g" /container/service/phpldapadmin/assets/apache2/phpldapadmin-ssl.conf
    fi

    a2ensite phpldapadmin-ssl

  else
    a2ensite phpldapadmin
  fi

  # phpLDAPadmin directory is empty, we use the bootstrap
  if [ ! "$(ls -A /var/www/phpldapadmin)" ]; then
    cp -R /var/www/phpldapadmin_bootstrap/* /var/www/phpldapadmin
    rm -rf /var/www/phpldapadmin_bootstrap

    echo "copy /container/service/phpldapadmin/assets/config.php to /var/www/phpldapadmin/config/config.php"
    cp -f /container/service/phpldapadmin/assets/config.php /var/www/phpldapadmin/config/config.php

    get_salt() {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpLDAPadmin cookie secret
    get_salt
    sed -i --follow-symlinks "s|{{ PHPLDAPADMIN_CONFIG_BLOWFISH }}|${salt}|g" /var/www/phpldapadmin/config/config.php

    append_to_servers() {
      TO_APPEND=$1
      sed -i --follow-symlinks "s|{{ PHPLDAPADMIN_SERVERS }}|${TO_APPEND}\n{{ PHPLDAPADMIN_SERVERS }}|g" /var/www/phpldapadmin/config/config.php
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

    # phpLDAPadmin servers config
    host_info(){

      local to_print=$1

      for info in $(complex-bash-env iterate "$2")
      do

        local isRow=$(complex-bash-env isRow "${!info}")

        if [ $isRow = true ]; then
          local key=$(complex-bash-env getRowKey "${!info}")
          local value=$(complex-bash-env getRowValue "${!info}")

          host_info "$to_print'$key'," "${value}"

        else
          local php_value=$(print_by_php_type $info)
          append_to_servers "\$servers->setValue($to_print$php_value);"
        fi

      done
    }

    # phpLDAPadmin config
    for host in $(complex-bash-env iterate "${PHPLDAPADMIN_LDAP_HOSTS}")
    do

      isRow=$(complex-bash-env isRow "${!host}")

      append_to_servers "\$servers->newServer('ldap_pla');"

      if [ $isRow = true ]; then
        hostname=$(complex-bash-env getRowKey "${!host}")
        info=$(complex-bash-env getRowValue "${!host}")

        append_to_servers "\$servers->setValue('server','name','$hostname');"
        append_to_servers "\$servers->setValue('server','host','$hostname');"
        host_info "" "$info"

      else
        append_to_servers "\$servers->setValue('server','name','${host}');"
        append_to_servers "\$servers->setValue('server','host','${host}');"
      fi
    done

    sed -i --follow-symlinks "/{{ PHPLDAPADMIN_SERVERS }}/d" /var/www/phpldapadmin/config/config.php

  fi

  # fix file permission
  find /var/www/ -type d -exec chmod 755 {} \;
  find /var/www/ -type f -exec chmod 644 {} \;
  chmod 400 /var/www/phpldapadmin/config/config.php
  chown www-data:www-data -R /var/www

  touch $FIRST_START_DONE
fi

exit 0
