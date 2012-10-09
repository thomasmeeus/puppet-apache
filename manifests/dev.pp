#
# == Class: apache::dev
#
# Installs package(s) required to build apache modules using apxs.
#
# Limitation: currently only works on redhat.
#
# Example usage:
#
#   include apache::dev
#
class apache::dev {
  $pkgname  = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd-devel',
    /Debian|Ubuntu/ => 'apache2-threaded-dev',
  }
  package { $pkgname:
    ensure  => present,
    require => Package['gcc'],
  }
}
