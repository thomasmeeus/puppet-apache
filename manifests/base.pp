/*

== Class: apache::base

Common building blocks between apache::debian and apache::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base {

  include apache::params

  $access_log = $apache::params::access_log
  $error_log  = $apache::params::error_log

  concat {"${apache::params::conf}/ports.conf":
    notify  => Service['apache'],
    require => Package['apache'],
  }

  # removed this folder originally created by common::concatfilepart
  file {"${apache::params::conf}/ports.conf.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file {'root directory':
    ensure  => directory,
    path    => $apache::params::root,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['apache'],
  }

  file {'log directory':
    ensure  => directory,
    path    => $apache::params::log,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['apache'],
  }

  user { 'apache user':
    ensure  => present,
    name    => $apache::params::user,
    require => Package['apache'],
    shell   => '/bin/sh',
  }

  group { 'apache group':
    ensure  => present,
    name    => $apache::params::user,
    require => Package['apache'],
  }

  package { 'apache':
    ensure => installed,
    name   => $apache::params::pkg,
  }

  service { 'apache':
    ensure     => $apache::params::service_status,
    name       => $apache::params::pkg,
    enable     => true,
    hasrestart => true,
    require    => Package['apache'],
  }
  $logrotate_paths = "${apache::params::root}/*/logs/*.log ${apache::params::log}/*log"
  file {'logrotate configuration':
    ensure  => present,
    path    => "/etc/logrotate.d/${apache::params::pkg}",
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => undef,
    content => template('apache/logrotate-httpd.erb'),
    require => Package['apache'],
  }

  apache::listen { $apache::params::default_port:
    ensure => present
  }
  apache::namevhost { "*:${apache::params::default_port}":
    ensure => present
  }

  apache::module {['alias', 'auth_basic', 'authn_file', 'authz_default', 'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env', 'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'cgi']:
    ensure => present,
    notify => Exec['apache-graceful'],
  }

  $statusfile_path = $::operatingsystem ? {
    /RedHat|CentOS/      => "${apache::params::conf}/conf.d/status.conf",
    /Ubuntu|Debian/      => "${apache::params::conf}/mods-available/status.conf",
  }
  $statusfile_source = $::operatingsystem ? {
    /RedHat|CentOS/ => "puppet:///modules/apache/${apache::params::conf}/conf/status.conf",
    /Debian|Ubuntu/ => "puppet:///modules/apache/${apache::params::conf}/mods-available/status.conf",
  }
  file {'default status module configuration':
    ensure  => present,
    path    => $statusfile_path,
    owner   => root,
    group   => root,
    source  => $statusfile_source,
    require => Module['status'],
    notify  => Exec['apache-graceful'],
  }

  file {'default virtualhost':
    ensure  => present,
    path    => "${apache::params::conf}/sites-available/default-vhost",
    content => template('apache/default-vhost.erb'),
    require => Package['apache'],
    notify  => Exec['apache-graceful'],
    before  => File["${apache::params::conf}/sites-enabled/000-default-vhost"],
    mode    => '0644',
  }

  if $apache::params::apache_disable_default_vhost {

    file { "${apache::params::conf}/sites-enabled/000-default-vhost":
      ensure => absent,
      notify => Exec['apache-graceful'],
    }

  } else {

    file { "${apache::params::conf}/sites-enabled/000-default-vhost":
      ensure => link,
      target => "${apache::params::conf}/sites-available/default-vhost",
      notify => Exec['apache-graceful'],
    }

    file { "${apache::params::root}/html":
      ensure  => directory,
    }

  }

  exec { 'apache-graceful':
    command     => '/usr/sbin/apachectl graceful',
    refreshonly => true,
    onlyif      => '/usr/sbin/apachectl configtest',
  }

  file {'/usr/local/bin/htgroup':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/apache/usr/local/bin/htgroup',
  }

  file { ["${apache::params::conf}/sites-enabled/default",
          "${apache::params::conf}/sites-enabled/000-default",
          "${apache::params::conf}/sites-enabled/default-ssl"]:
    ensure => absent,
    notify => Exec['apache-graceful'],
  }

}
