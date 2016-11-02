/*
== Class: cegeka_apache::collectd

Configures collectd's apache plugin. This gathers data from apache's
server-status and stores it in rrd files, from which you can make nice
graphs.

You will need collectd up and running, which can be cone using the
puppet-collectd module.

Requires:
- Class['collectd']

Usage:
  include cegeka_apache
  include collectd
  include cegeka_apache::collectd

*/
class cegeka_apache::collectd {

  if ($::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS') and $::lsbmajdistrelease > '4' {

    package { 'collectd-apache':
      ensure => present,
      before => Collectd::Plugin['cegeka_apache'],
    }
  }

  collectd::plugin { 'apache':
    lines   => ['URL "http://localhost/server-status?auto"'],
    require => Package['curl'],
  }

}
