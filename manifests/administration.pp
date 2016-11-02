class cegeka_apache::administration {

  include cegeka_apache::params

  $distro_specific_apache_sudo = $::operatingsystem ? {
    /RedHat|CentOS/ => "/usr/sbin/apachectl, /sbin/service ${cegeka_apache::params::pkg}",
    /Debian|Ubuntu/ => '/usr/sbin/apache2ctl',
  }

  group { 'apache-admin':
    ensure => present,
  }

  # used in erb template
  $wwwpkgname = $cegeka_apache::params::pkg
  $wwwuser    = $cegeka_apache::params::user

  sudo::directive { 'apache-administration':
    ensure  => present,
    content => template('cegeka_apache/sudoers.apache.erb'),
    require => Group['apache-admin'],
  }

}
