define cegeka_apache::userdirinstance ($vhost, $ensure=present) {

  include cegeka_apache::params

  $confseltype = $::operatingsystem ? {
    'RedHat'  => 'httpd_config_t',
    'CentOS'  => 'httpd_config_t',
    default   => undef,
  }
  file { "${cegeka_apache::params::root}/${vhost}/conf/userdir.conf":
    ensure      => $ensure,
    source      => 'puppet:///modules/cegeka_apache/userdir.conf',
    seltype     => $confseltype,
    notify      => Exec['cegeka_apache-graceful'],
  }
}
