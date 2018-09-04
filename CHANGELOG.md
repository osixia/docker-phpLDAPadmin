# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.7.2] - 2018-09-04
### Added
  - Ability to sepcifiy different values for ldap 'host' and 'name' #46

## [0.7.1] - 2017-12-05
### Added
  - Opcache config

### Changed
  - Optimise apache config
  - Upgrade baseimage to web-baseimage:1.1.1

## [0.7.0] - 2017-07-19
### Added
  - add config.php in config folder

### Changed
  - Upgrade baseimage to web-baseimage:1.1.0 (debian stretch, php7)

## [0.6.12] - 2017-03-27
### Changed
  - Upgrade baseimage to web-baseimage:1.0.0

### Fixed 
  - Fixes Parse error: syntax error, unexpected '}' in config.php on line 68 #23

## [0.6.11] - 2016-09-02
### Changed
  - Upgrade baseimage to web-baseimage:0.1.10

## [0.6.10] - 2016-07-26
### Added
  - Add PHPLDAPADMIN_SERVER_PATH environment variable

## [0.6.9] - 2016-06-09
### Changed
  - Upgrade baseimage to web-baseimage:0.1.10

## [0.6.8] - 2016-02-20
### Changed
  - Upgrade baseimage to web-baseimage:0.1.9

## [0.6.7] - 2016-01-25
### Changed
  - Upgrade baseimage to web-baseimage:0.1.8

## [0.6.6] - 2015-12-16
### Added 
  - Makefile with build no cache

### Changed
  - Upgrade baseimage to web-baseimage:0.1.7

## [0.6.5] - 2015-11-20
### Changed
  - Upgrade baseimage to web-baseimage:0.1.6

## [0.6.4] - 2015-11-19
### Changed
  - Upgrade baseimage to web-baseimage:0.1.5
  - externalise ldap-client config from phpLdapAdmin

### Removed
  - Remove listen on http when https is enable

## [0.6.3] - 2015-10-26
### Changed
  - Upgrade baseimage to web-baseimage:0.1.3

## [0.6.2] - 2015-08-21
### Changed
  - Better way to add custom config

## [0.6.1] - 2015-08-20
### Changed
  - Upgrade baseimage to web-baseimage:0.1.1
  - Rename environment variables

## [0.6.0] - 2015-07-24
### Changed
  - Use new baseimage: light-baseimage

## [0.5.1] - 2015-05-17
### Fixed
  - Fix #1 (can't activate SSL with own certificates)

## [0.5.0] - 2015-03-03
New version initial release, no changelog before this sorry.

[0.7.2]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.12...v0.7.0
[0.6.12]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.11...v0.6.12
[0.6.11]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.10...v0.6.11
[0.6.10]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.9...v0.6.10
[0.6.9]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.8...v0.6.9
[0.6.8]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.7...v0.6.8
[0.6.7]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.6...v0.6.7
[0.6.6]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.5...v0.6.6
[0.6.5]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.4...v0.6.5
[0.6.4]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.3...v0.6.4
[0.6.3]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/osixia/docker-phpLDAPadmin/compare/v0.1.0...v0.5.0