class cegeka_apache::debian {
  include cegeka_apache::base
  include cegeka_apache::params

  $mpm_package = $cegeka_apache::apache_mpm_type ? {
    ''      => 'apache2-mpm-prefork',
    default => "apache2-mpm-${cegeka_apache::apache_mpm_type}",
  }

  package { $mpm_package:
    ensure  => installed,
    require => Package['cegeka_apache'],
  }

  # directory not present in lenny
  file { "${cegeka_apache::params::root}/apache2-default":
    ensure => absent,
    force  => true,
  }

  file { "${cegeka_apache::params::root}/index.html":
    ensure => absent,
  }

  file { "${cegeka_apache::params::root}/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => '<html><body><h1>It works!</h1></body></html>',
  }

  file { "${cegeka_apache::params::conf}/conf.d/servername.conf":
    content => "ServerName ${::fqdn}\n",
    notify  => Service['cegeka_apache'],
    require => Package['cegeka_apache'],
  }

}
