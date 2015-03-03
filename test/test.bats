#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "http response" {

  tmp_file="$BATS_TMPDIR/docker-test"
  
  run_image
  wait_service apache2 php5-fpm
  curl --silent --insecure https://$CONTAINER_IP >> $tmp_file
  run grep -c "Use the menu to the left to navigate" $tmp_file
  rm $tmp_file
  clear_container

  [ "$status" -eq 0 ]
  [ "$output" = "1" ]

}

@test "http response with ldap login" {

  tmp_file="$BATS_TMPDIR/docker-test"
  
  # we start a new openldap container
  LDAP_CID=$(docker run -d osixia/openldap:0.10.0)
  LDAP_IP=$(get_container_ip_by_cid $LDAP_CID)

  # we start the wordpress container and set DB_HOSTS
  run_image -e LDAP_HOSTS=$LDAP_IP

  # wait openldap 
  wait_service_by_cid $LDAP_CID slapd

  # wait phpLDAPadmin container apache2 service
  wait_service apache2 php5-fpm

  curl -L --silent --insecure -c $BATS_TMPDIR/cookie.txt https://$CONTAINER_IP >> $tmp_file

  curl -L --silent --insecure -b $BATS_TMPDIR/cookie.txt https://$CONTAINER_IP/cmd.php -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0'  -H 'Connection: keep-alive' --data 'cmd=login&server_id=1&nodecode%5Blogin_pass%5D=1&login=cn%3Dadmin%2Cdc%3Dexample%2Cdc%3Dorg&login_pass=admin&submit=Authenticate' --compressed >> $tmp_file

  run grep -c "Logged in as:" $tmp_file

  rm $tmp_file
  rm $BATS_TMPDIR/cookie.txt
  clear_container

  # clear openldap container
  clear_containers_by_cid $LDAP_CID

  [ "$status" -eq 0 ]
  [ "$output" = "1" ]

}