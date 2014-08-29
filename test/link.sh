#!/bin/sh

#start a openldap container
openldap="osixia-phpldapadmin-openldap"

echo "docker run --name $openldap -d osixia/openldap"
docker run --name $openldap -d osixia/openldap 
sleep 10

dir=$(dirname $0)

runOptions="--link osixia-phpldapadmin-openldap:ldap"
. $dir/tools/run-container.sh

echo "curl --insecure -c $testDir/cookie.txt https://$IP"
curl --insecure -c $testDir/cookie.txt https://$IP

echo "curl --insecure  https://$IP/cmd.php -L -b $testDir/cookie.txt  -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0'  -H 'Connection: keep-alive' --data 'cmd=login&server_id=1&nodecode%5Blogin_pass%5D=1&login=cn%3Dadmin%2Cdc%3Dexample%2Cdc%3Dcom&login_pass=toor&submit=Authenticate' --compressed"

curl --insecure https://$IP/cmd.php -L -b $testDir/cookie.txt  -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0'  -H 'Connection: keep-alive' --data 'cmd=login&server_id=1&nodecode%5Blogin_pass%5D=1&login=cn%3Dadmin%2Cdc%3Dexample%2Cdc%3Dcom&login_pass=toor&submit=Authenticate' --compressed

docker stop $openldap
docker rm $openldap

$dir/tools/delete-container.sh
