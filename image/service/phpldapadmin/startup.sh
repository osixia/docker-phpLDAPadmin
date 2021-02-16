#!/bin/bash -e



# ensure_uid $servicename $intended_uid $intended_gid $filename(s)
# Taken from OpenLDAP image; should be moved to the shared image at some point, then used by this script and OpenLDAP both
function	ensure_uid() {
    servicename=$1
    intended_uid=${2:-33}
    intended_gid=${3:-33}
    # Because there are 3 positional params
    shift 3

    log-helper info "$servicename user and group adjustments"

    log-helper info "get current $servicename uid/gid info inside container"
    CUR_USER_GID=`id -g $servicename || true`
    CUR_USER_UID=`id -u $servicename || true`

    SERVICE_UIDGID_CHANGED=false
    if [ "$intended_uid" != "$CUR_USER_UID" ]; then
        log-helper info "CUR_USER_UID (${CUR_USER_UID}) does't match intended_uid (${intended_uid}), adjusting..."
        usermod -o -u "$intended_uid" $servicename
        SERVICE_UIDGID_CHANGED=true
    fi
    if [ "$intended_gid" != "$CUR_USER_GID" ]; then
        log-helper info "CUR_USER_GID (${CUR_USER_GID}) does't match intended_gid (${intended_gid}), adjusting..."
        groupmod -o -g "$intended_gid" $servicename
        SERVICE_UIDGID_CHANGED=true
    fi

    log-helper info '-------------------------------------'
    log-helper info '$servicename GID/UID'
    log-helper info '-------------------------------------'
    log-helper info "User uid:    $(id -u $servicename)"
    log-helper info "User gid:    $(id -g $servicename)"
    log-helper info "uid/gid changed: ${SERVICE_UIDGID_CHANGED}"
    log-helper info "-------------------------------------"

    # fix file permissions
    if [ "${DISABLE_CHOWN,,}" == "false" ]; then
      log-helper info "updating file uid/gid ownership"
      if [ ! -z "$*" ]; then
          for file in $*; do
              chown -R $servicename:$servicename $file
          done
      fi
    fi

    return $SERVICE_UIDGID_CHANGED
}

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
if [ ! "$(ls -A -I lost+found /var/www/phpldapadmin)" ]; then

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
    sed -i "s|{{ PHPLDAPADMIN_CONFIG_BLOWFISH }}|${salt}|g" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php

    append_to_file() {
      TO_APPEND=$1
      sed -i "s|{{ PHPLDAPADMIN_SERVERS }}|${TO_APPEND}\n{{ PHPLDAPADMIN_SERVERS }}|g" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php
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

        if [ "${PHPLDAPADMIN_LDAP_HOSTS_FRIENDLY,,}" != "true" ]; then
          append_to_file "\$servers->setValue('server','host','$hostname');"
        fi
        append_to_file "\$servers->setValue('server','name','$hostname');"
        host_info "" "$info"

      else
        append_to_file "\$servers->setValue('server','name','${!host}');"
        append_to_file "\$servers->setValue('server','host','${!host}');"
      fi
    done

    sed -i "/{{ PHPLDAPADMIN_SERVERS }}/d" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php

    touch $FIRST_START_DONE
  fi

  log-helper debug "link ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php to /var/www/phpldapadmin/config/config.php"
  cp -f ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php /var/www/phpldapadmin/config/config.php

fi

PHPLDAPADMIN_WWW_DATA_UID=${PHPLDAPADMIN_WWW_DATA_UID:-33}
PHPLDAPADMIN_WWW_DATA_GID=${PHPLDAPADMIN_WWW_DATA_GID:-33}
ensure_uid www-data $PHPLDAPADMIN_WWW_DATA_UID $PHPLDAPADMIN_WWW_DATA_GID /var/www

##### For each template...
templatedir=${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/templates
echo "Finding templates"
find ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/
shopt -s nullglob
for action in creation modification; do
  for template in ${templatedir}/${action}/*.xml; do
    basename=`basename $template`
    log-helper info "Linking $action template for $template"
    target=/var/www/phpldapadmin/templates/$action/$basename
    ln -sf $template $target
    chown $PHPLDAPADMIN_WWW_DATA_UID:$PHPLDAPADMIN_WWW_DATA_GID $target
  done
done
shopt -u nullglob

# fix file permission
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;

# symlinks special (chown -R don't follow symlinks)
# Should be redone because of ensure_uid above
chown www-data:www-data /var/www/phpldapadmin/config/config.php
chmod 400 /var/www/phpldapadmin/config/config.php

exit 0
