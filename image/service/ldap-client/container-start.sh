#!/bin/bash -e

FIRST_START_DONE="/etc/docker-ldap-client-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  if [ "${PHPLDAPADMIN_LDAP_CLIENT_TLS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-helper "/container/service/ldap-client/assets/certs/${PHPLDAPADMIN_LDAP_CLIENT_TLS_CRT_FILENAME}" "/container/service/ldap-client/assets/certs/${PHPLDAPADMIN_LDAP_CLIENT_TLS_KEY_FILENAME}" --ca-crt=/container/service/ldap-client/assets/certs/${PHPLDAPADMIN_LDAP_CLIENT_TLS_CA_CRT_FILENAME} --gnutls

    # ldap client config
    sed -i --follow-symlinks "s,TLS_CACERT.*,TLS_CACERT /container/service/ldap-client/assets/certs/${PHPLDAPADMIN_LDAP_CLIENT_TLS_CA_CRT_FILENAME},g" /etc/ldap/ldap.conf
    echo "TLS_REQCERT $PHPLDAPADMIN_LDAP_CLIENT_TLS_REQCERT" >> /etc/ldap/ldap.conf

    www_data_homedir=$( getent passwd "www-data" | cut -d: -f6 )

    [[ -f "$www_data_homedir/.ldaprc" ]] && rm -f $www_data_homedir/.ldaprc
    touch $www_data_homedir/.ldaprc
    echo "TLS_CERT /container/service/ldap-client/assets/certs/${PHPLDAPADMIN_LDAP_CLIENT_TLS_CRT_FILENAME}" >> $www_data_homedir/.ldaprc
    echo "TLS_KEY /container/service/ldap-client/assets/certs/${PHPLDAPADMIN_LDAP_CLIENT_TLS_KEY_FILENAME}" >> $www_data_homedir/.ldaprc

    chown www-data:www-data -R /container/service/ldap-client/assets/certs/
  fi

  touch $FIRST_START_DONE
fi

exit 0
