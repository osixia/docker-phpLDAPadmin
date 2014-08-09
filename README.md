# docker-phpLDAPadmin

A version of the [osixia/phpldapadmin][1] image with the following improvements:

- A [bug on not finding "password_hash" when trying to create a new user][2] is fixed
- phpLDAPadmin is also exposed via HTTPS on port 443 (using a self-signed certificate)

### Quick start
Run docker image with your custom environment variables :

    docker run -p 80:80 -p 443:443 \
               -e LDAP_HOST=ldap.example.com \
               -e LDAP_BASE_DN=dc=example,dc=com \
               -e LDAP_LOGIN_DN=cn=admin,dc=example,dc=com \
               -d rabejens/phpldapadmin

phpLDAPadmin should be running on http://localhost and https://localhost

### Build image from sources

Clone the repository 

    git clone https://github.com/rabejens/docker-phpLDAPadmin
    cd docker-phpLDAPadmin

Build image

    docker build -t phpldapadmin .

[1]: https://github.com/osixia/docker-phpLDAPadmin
[2]: http://stackoverflow.com/questions/20673186/getting-error-for-setting-password-feild-when-creating-generic-user-account-phpl