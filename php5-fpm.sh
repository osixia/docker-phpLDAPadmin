#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
# -u Treat unset variables as an error when substituting
set -eu

status () {
  echo "---> ${@}" >&2
}

if [ ! -e /etc/php5/fpm/docker_bootstrapped ]; then
  status "configuring php5-fpm for first run"

  # php-fpm config
  sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

  touch /etc/php5/fpm/docker_bootstrapped
else
  status "found already-configured php5-fpm"
fi

status "starting php5-fpm"
set -x
exec service php5-fpm start
