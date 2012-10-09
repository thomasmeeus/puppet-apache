define apache::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  include apache::params

  $location = $name

  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${apache::params::root}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template('apache/webdav-svn.erb'),
    seltype => $confseltype,
    notify  => Exec['apache-graceful'],
  }

}
