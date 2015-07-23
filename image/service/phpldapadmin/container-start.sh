#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpldapadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpLDAPadmin vhost
  if [ "${HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-helper "/container/service/phpldapadmin/assets/apache2/ssl/$SSL_CRT_FILENAME" "/container/service/phpldapadmin/assets/apache2/ssl/$SSL_KEY_FILENAME" --ca-crt=/container/service/phpldapadmin/assets/apache2/ssl/$SSL_CA_CRT_FILENAME

    # add CA certificat config if CA cert exists
    if [ -e "/container/service/phpldapadmin/assets/apache2/ssl/$SSL_CA_CRT_FILENAME" ]; then
      sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" /container/service/phpldapadmin/assets/apache2/phpldapadmin-ssl.conf
    fi

    a2ensite phpldapadmin-ssl

  else
    a2ensite phpldapadmin
  fi

  # phpLDAPadmin directory is empty, we use the bootstrap
  if [ ! "$(ls -A /var/www/phpldapadmin)" ]; then
    cp -R /var/www/phpldapadmin_bootstrap/* /var/www/phpldapadmin
    rm -rf /var/www/phpldapadmin_bootstrap

    get_salt() {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:|{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpLDAPadmin cookie secret
    get_salt
    sed -i "s/blowfish'] = '/blowfish'] = '${salt}/g" /var/www/phpldapadmin/config/config.php

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
        echo "\$servers->setValue($to_print'$key',$php_value);" >> /var/www/phpldapadmin/config/config.php

      # it's just a not empty value
      elif [ -n "$value" ]; then
        local php_value=$(print_by_php_type $value)
        echo "\$servers->setValue($to_print'$key',$php_value);" >> /var/www/phpldapadmin/config/config.php
      fi
    }

    # phpLDAPadmin config
    LDAP_HOSTS=($LDAP_HOSTS)
    for host in "${LDAP_HOSTS[@]}"
    do

      #host var contain a variable name, we access to the variable value and cast it to a table
      infos=(${!host})

      echo "\$servers->newServer('ldap_pla');" >> /var/www/phpldapadmin/config/config.php

      # it's a table of infos
      if [ "${#infos[@]}" -gt "1" ]; then
        echo "\$servers->setValue('server','name','${!infos[0]}');" >> /var/www/phpldapadmin/config/config.php
        echo "\$servers->setValue('server','host','${!infos[0]}');" >> /var/www/phpldapadmin/config/config.php
        host_infos "" ${infos[1]}

      # it's just a host name
      # stored in a variable
      elif [ -n "${!host}" ]; then
        echo "\$servers->setValue('server','name','${!host}');" >> /var/www/phpldapadmin/config/config.php
        echo "\$servers->setValue('server','host','${!host}');" >> /var/www/phpldapadmin/config/config.php

      # directly
      else
        echo "\$servers->setValue('server','name','${host}');" >> /var/www/phpldapadmin/config/config.php
        echo "\$servers->setValue('server','host','${host}');" >> /var/www/phpldapadmin/config/config.php
      fi
    done

    if [ "${USE_LDAP_CLIENT_SSL,,}" == "true" ]; then

      # check certificat and key or create it
      /sbin/ssl-helper "/container/service/phpldapadmin/assets/ssl/${LDAP_CRT_FILENAME}" "/container/service/phpldapadmin/assets/ssl/${LDAP_KEY_FILENAME}" --ca-crt=/container/service/phpldapadmin/assets/ssl/${LDAP_CA_CRT_FILENAME} --gnutls

      # ldap client config
      sed -i "s,TLS_CACERT.*,TLS_CACERT /container/service/phpldapadmin/assets/ssl/${LDAP_CA_CRT_FILENAME},g" /etc/ldap/ldap.conf
      echo "TLS_REQCERT $LDAP_REQCERT" >> /etc/ldap/ldap.conf

      www_data_homedir=$( getent passwd "www-data" | cut -d: -f6 )

      [[ -f "$www_data_homedir/.ldaprc" ]] && rm -f $www_data_homedir/.ldaprc
      touch $www_data_homedir/.ldaprc
      echo "TLS_CERT /container/service/phpldapadmin/assets/ssl/${LDAP_CRT_FILENAME}" >> $www_data_homedir/.ldaprc
      echo "TLS_KEY /container/service/phpldapadmin/assets/ssl/${LDAP_KEY_FILENAME}" >> $www_data_homedir/.ldaprc

      chown www-data:www-data -R /container/service/phpldapadmin/assets/ssl/
    fi

  fi

  # Fix file permission
  find /var/www/ -type d -exec chmod 755 {} \;
  find /var/www/ -type f -exec chmod 644 {} \;
  chmod 400 /var/www/phpldapadmin/config/config.php
  chown www-data:www-data -R /var/www

  touch $FIRST_START_DONE
fi

exit 0
