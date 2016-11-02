define cegeka_apache::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  include cegeka_apache::params

  $location = $name

  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${cegeka_apache::params::root}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template('cegeka_apache/webdav-svn.erb'),
    seltype => $confseltype,
    notify  => Exec['apache-graceful'],
  }

}
