# docker-phpLDAPadmin

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


## License

The MIT License (MIT)

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
