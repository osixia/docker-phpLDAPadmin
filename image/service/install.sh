#!/bin/bash -e
# this script is run during the image build

# Add phpMyAdmin virtualhosts
ln -s /osixia/phpldapadmin/apache2/phpldapadmin.conf /etc/apache2/sites-available/phpldapadmin.conf
ln -s /osixia/phpldapadmin/apache2/phpldapadmin-ssl.conf /etc/apache2/sites-available/phpldapadmin-ssl.conf
ln -s /osixia/phpldapadmin/config.php /var/www/phpldapadmin/config/config.php

cat /osixia/phpldapadmin/php5-fpm/pool.conf >> /etc/php5/fpm/pool.d/www.conf

mkdir -p /var/www/tmp
chown www-data:www-data /var/www/tmp

# Remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Delete unnecessary files
rm -rf /var/www/phpldapadmin/doc

cd /var/www/phpldapadmin
patch -p1 < /osixia/phpldapadmin/php5.5.patch

# fix php5-fpm $_SERVER['SCRIPT_NAME'] false value with cgi.fix_pathinfo=0
sed -i "s/'SCRIPT_NAME'/'PATH_INFO'/g" /var/www/phpldapadmin/lib/common.php