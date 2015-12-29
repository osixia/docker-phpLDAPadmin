#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpldapadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpLDAPadmin vhost
  if [ "${PHPLDAPADMIN_HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    cfssl-helper phpmyadmin "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CRT_FILENAME" "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_KEY_FILENAME" "/container/service/phpldapadmin/assets/apache2/certs/$PHPLDAPADMIN_HTTPS_CA_CRT_FILENAME"

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
    host_infos() {

      local to_print=$1
      local infos=(${!2})

      for info in "${infos[@]}"
      do
        host_infos_value "$to_print" "$info"
      done
    }

    host_infos_value(){

      local to_print=$1
      local info_key_value=(${!2})

      local key=${!info_key_value[0]}
      local value=(${!info_key_value[1]})

      local value_of_value_table=(${!value})

      # it's a table of values
      if [ "${#value[@]}" -gt "1" ]; then
        host_infos "$to_print'$key'," "${info_key_value[1]}"

      # the value of value is a table
      elif [ "${#value_of_value_table[@]}" -gt "1" ]; then
        host_infos_value "$to_print'$key'," "$value"

      # the value contain a not empty variable
      elif [ -n "${!value}" ]; then
        local php_value=$(print_by_php_type ${!value})
        append_to_servers "\$servers->setValue($to_print'$key',$php_value);"

      # it's just a not empty value
      elif [ -n "$value" ]; then
        local php_value=$(print_by_php_type $value)
        append_to_servers "\$servers->setValue($to_print'$key',$php_value);"
      fi
    }

    # phpLDAPadmin config
    PHPLDAPADMIN_LDAP_HOSTS=($PHPLDAPADMIN_LDAP_HOSTS)
    for host in "${PHPLDAPADMIN_LDAP_HOSTS[@]}"
    do

      # host var contain a variable name, we access to the variable value and cast it to a table
      infos=(${!host})

      append_to_servers "\$servers->newServer('ldap_pla');"

      # it's a table of infos
      if [ "${#infos[@]}" -gt "1" ]; then
        append_to_servers "\$servers->setValue('server','name','${!infos[0]}');"
        append_to_servers "\$servers->setValue('server','host','${!infos[0]}');"
        host_infos "" ${infos[1]}

      # it's just a host name
      # stored in a variable
      elif [ -n "${!host}" ]; then
        append_to_servers "\$servers->setValue('server','name','${!host}');"
        append_to_servers "\$servers->setValue('server','host','${!host}');"

      # directly
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
