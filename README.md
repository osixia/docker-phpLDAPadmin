docker-phpLDAPadmin
===================

A docker.io image for phpLDAPadmin

### Usage

Build image from sources :

    git clone https://github.com/osixia/docker-phpLDAPadmin
    cd docker-phpLDAPadmin
    sudo docker.io build -t phpLDAPadmin --no-cache .

Run docker image with your custom environment variables :

    docker run -e LDAP_HOST=127.0.0.1 \
            -e PHPLDAPADMIN_BASE_DN=dc=example,dc=com \
            -e PHPLDAPADMIN_LOGIN_DN=cn=admin,dc=test,dc=com \
            -d phpLDAPadmin

to be completed :)
