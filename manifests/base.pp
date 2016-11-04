/*

== Class: cegeka_apache::base

Common building blocks between cegeka_apache::debian and cegeka_apache::redhat.

It shouldn't be necessary to directly include this class.

*/
class cegeka_apache::base {

  include cegeka_apache::params

  $access_log = $cegeka_apache::params::access_log
  $error_log  = $cegeka_apache::params::error_log

  concat {"${cegeka_apache::params::conf}/ports.conf":
    notify  => Service['cegeka_apache'],
    require => Package['cegeka_apache'],
  }

  # removed this folder originally created by common::concatfilepart
  file {"${cegeka_apache::params::conf}/ports.conf.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file {'root directory':
    ensure  => directory,
    path    => $cegeka_apache::params::root,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['cegeka_apache'],
  }

  file {'log directory':
    ensure  => directory,
    path    => $cegeka_apache::params::log,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['cegeka_apache'],
  }

  user { 'apache user':
    ensure  => present,
    name    => $cegeka_apache::params::user,
    require => Package['cegeka_apache'],
    shell   => '/bin/sh',
  }

  group { 'apache group':
    ensure  => present,
    name    => $cegeka_apache::params::user,
    require => Package['cegeka_apache'],
  }

  package { 'cegeka_apache':
    ensure => installed,
    name   => $cegeka_apache::params::pkg,
  }

  service { 'cegeka_apache':
    ensure     => $cegeka_apache::params::service_status,
    name       => $cegeka_apache::params::pkg,
    enable     => true,
    hasrestart => true,
    require    => Package['cegeka_apache'],
  }
  $logrotate_paths = "${cegeka_apache::params::root}/*/logs/*.log ${cegeka_apache::params::log}/*log"
  file {'logrotate configuration':
    ensure  => present,
    path    => "/etc/logrotate.d/${cegeka_apache::params::pkg}",
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => undef,
    content => template('cegeka_apache/logrotate-httpd.erb'),
    require => Package['cegeka_apache'],
  }

  cegeka_apache::listen { $cegeka_apache::params::default_port:
      ensure => present
  }
  
  if ($::operatingsystemmajrelease < 7) {
    cegeka_apache::namevhost { "*:${cegeka_apache::params::default_port}":
      ensure => present
    }
  }

  $real_apache_modules = $::operatingsystemrelease ? {
    /5.*/ => ['alias', 'auth_basic', 'authn_file', 'authz_default', 'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env', 'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'cgi'],
    /6.*/ => ['alias', 'auth_basic', 'authn_file', 'authz_default', 'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env', 'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'cgi'],
    /7.*/ => ['alias', 'auth_basic', 'authn_file', 'authz_core', 'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env', 'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'mpm_prefork', 'unixd', 'access_compat', 'socache_shmcb', 'systemd']
  }

  cegeka_apache::module { $real_apache_modules :
    ensure => present,
    notify => Exec['cegeka_apache-graceful'],
  }

  $statusfile_path = $::operatingsystem ? {
    /RedHat|CentOS/      => "${cegeka_apache::params::conf}/conf.d/status.conf",
    /Ubuntu|Debian/      => "${cegeka_apache::params::conf}/mods-available/status.conf",
  }
  $statusfile_source = $::operatingsystem ? {
    /RedHat|CentOS/ => "puppet:///modules/cegeka_apache/${cegeka_apache::params::conf}/conf/status.conf",
    /Debian|Ubuntu/ => "puppet:///modules/cegeka_apache/${cegeka_apache::params::conf}/mods-available/status.conf",
  }
  file {'default status module configuration':
    ensure  => present,
    path    => $statusfile_path,
    owner   => root,
    group   => root,
    source  => $statusfile_source,
    require => Module['status'],
    notify  => Exec['cegeka_apache-graceful'],
  }

  file {'default virtualhost':
    ensure  => present,
    path    => "${cegeka_apache::params::conf}/sites-available/default-vhost",
    content => template('cegeka_apache/default-vhost.erb'),
    require => Package['cegeka_apache'],
    notify  => Exec['cegeka_apache-graceful'],
    before  => File["${cegeka_apache::params::conf}/sites-enabled/000-default-vhost"],
    mode    => '0644',
  }

  if $cegeka_apache::params::apache_disable_default_vhost {

    file { "${cegeka_apache::params::conf}/sites-enabled/000-default-vhost":
      ensure => absent,
      notify => Exec['cegeka_apache-graceful'],
    }

  } else {

    file { "${cegeka_apache::params::conf}/sites-enabled/000-default-vhost":
      ensure => link,
      target => "${cegeka_apache::params::conf}/sites-available/default-vhost",
      notify => Exec['cegeka_apache-graceful'],
    }

    file { "${cegeka_apache::params::root}/html":
      ensure  => directory,
    }

  }

  exec { 'cegeka_apache-graceful':
    command     => '/usr/sbin/apachectl graceful',
    refreshonly => true,
    onlyif      => '/usr/sbin/apachectl configtest',
  }

  file {'/usr/local/bin/htgroup':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/cegeka_apache/usr/local/bin/htgroup',
  }

  file { ["${cegeka_apache::params::conf}/sites-enabled/default",
          "${cegeka_apache::params::conf}/sites-enabled/000-default",
          "${cegeka_apache::params::conf}/sites-enabled/default-ssl"]:
    ensure => absent,
    notify => Exec['cegeka_apache-graceful'],
  }

}
