class apache::debian {
  include apache::base
  include apache::params

  $mpm_package = $apache::apache_mpm_type ? {
    ''      => 'apache2-mpm-prefork',
    default => "apache2-mpm-${apache::apache_mpm_type}",
  }

  package { $mpm_package:
    ensure  => installed,
    require => Package['apache'],
  }

  # directory not present in lenny
  file { "${apache::params::root}/apache2-default":
    ensure => absent,
    force  => true,
  }

  file { "${apache::params::root}/index.html":
    ensure => absent,
  }

  file { "${apache::params::root}/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => '<html><body><h1>It works!</h1></body></html>',
  }

  file { "${apache::params::conf}/conf.d/servername.conf":
    content => "ServerName ${::fqdn}\n",
    notify  => Service['apache'],
    require => Package['apache'],
  }

}
