/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see cegeka_apache::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  include cegeka_apache
  or
  class { 'apache':
    apache_vhost_root => '/data/www',
    ensure_status     => 'running',
    default_port      => '8080',
  }

*/
class cegeka_apache($apache_vhost_root='',$ensure_status='',$default_port='80') {
  case $::operatingsystem {
    Debian,Ubuntu:  { include cegeka_apache::debian}
    RedHat,CentOS:  { include cegeka_apache::redhat}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
