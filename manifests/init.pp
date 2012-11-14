/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see apache::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  include apache
  or
  class { 'apache':
    apache_vhost_root => '/data/www',
    ensure_status     => 'running'
  }

*/
class apache($apache_vhost_root='',$ensure_status='') {
  case $::operatingsystem {
    Debian,Ubuntu:  { include apache::debian}
    RedHat,CentOS:  { include apache::redhat}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
