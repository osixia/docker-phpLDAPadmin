docker-phpLDAPadmin
===================

A docker.io image for phpLDAPadmin

### Quick start
Run docker image with your custom environment variables :

    docker run -p 80:80 -e LDAP_HOST=ldap.example.com \
               -e PHPLDAPADMIN_BASE_DN=dc=example,dc=com \
               -e PHPLDAPADMIN_LOGIN_DN=cn=admin,dc=example,dc=com \
               -d osixia/phpldapadmin

phpLDAPadmin should be running on http://localhost

### Build image from sources

Clone the repository 

    git clone https://github.com/osixia/docker-phpLDAPadmin
    cd docker-phpLDAPadmin

Build image

    docker build -t phpldapadmin .

to be completed :)
