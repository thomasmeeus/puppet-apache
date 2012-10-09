define apache::webdav::instance ($vhost, $ensure=present, $directory=false,$mode=2755) {

  include apache::params

  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${apache::params::root}/${vhost}/private/webdav-${name}"
  }

  $real_ensure = $ensure ? {
    present => directory,
    absent  => absent,
  }
  file {$davdir:
    ensure  => $real_ensure,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => $mode,
  }

  # configuration
  $sysseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${apache::params::root}/${vhost}/conf/webdav-${name}.conf":
    ensure  => $ensure,
    content => template('apache/webdav-config.erb'),
    seltype => $sysseltype,
    require => File[$davdir],
    notify  => Exec['apache-graceful'],
  }
}
