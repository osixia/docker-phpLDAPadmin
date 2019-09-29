#!/bin/bash -e
# this script is run during the image build

cat /container/service/phpldapadmin/assets/php7.3-fpm/pool.conf >> /etc/php/7.3/fpm/pool.d/www.conf
rm /container/service/phpldapadmin/assets/php7.3-fpm/pool.conf

cp -f /container/service/phpldapadmin/assets/php7.3-fpm/opcache.ini /etc/php/7.3/fpm/conf.d/opcache.ini
rm /container/service/phpldapadmin/assets/php7.3-fpm/opcache.ini

mkdir -p /var/www/tmp
chown www-data:www-data /var/www/tmp

# remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Add apache modules
a2enmod deflate expires

# delete unnecessary files
rm -rf /var/www/phpldapadmin_bootstrap/doc
