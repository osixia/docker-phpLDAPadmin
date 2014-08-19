# docker-phpLDAPadmin

A docker.io image to run phpLDAPadmin

## Quick start

### Get phpLDAPadmin in 1''
Run docker container with your custom environment variables :

    sudo docker.io run -p 443:443 \
               -e LDAP_HOST=ldap.example.com \
               -e LDAP_BASE_DN=dc=example,dc=com \
               -e LDAP_LOGIN_DN=cn=admin,dc=example,dc=com \
               -d osixia/phpldapadmin

phpLDAPadmin should be running on https://localhost

### Whant more ? Openldap & phpLDAPadmin in 2''

First launch openldap:
 
    sudo docker.io run -p 443:443 \
               -e LDAP_HOST=ldap.example.com \
               -e LDAP_BASE_DN=dc=example,dc=com \
               -e LDAP_LOGIN_DN=cn=admin,dc=example,dc=com \
               -d osixia/phpldapadmin

    More information : https://github.com/osixia/docker-openldap

Then run phpLDAPadmin image linked to openldap container

Then link openldap container to phpLDAPadmin container:


### nginx SSL configuration

The details for the self-signed certificate can be defined with the following environment variables:

| Variable         | Default           |
| ---------------- | ----------------- |
| SSL_COUNTRY      | XX                |
| SSL_STATE        | Some-State        |
| SSL_LOCATION     | Some-Location     |
| SSL_ORGANIZATION | Some-Organization |
| SSL_COMMON_NAME  | Some-Common-Name  |

### Build image from sources

Clone the repository 

    git clone https://github.com/rabejens/docker-phpLDAPadmin
    cd docker-phpLDAPadmin

Build image

    docker build -t phpldapadmin .

[1]: https://github.com/osixia/docker-phpLDAPadmin
[2]: http://stackoverflow.com/questions/20673186/getting-error-for-setting-password-feild-when-creating-generic-user-account-phpl
