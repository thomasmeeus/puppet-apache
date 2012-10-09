define apache::aw-stats($ensure=present, $aliases=[]) {

  include apache::params

  # used in ERB template
  $wwwroot = $apache::params::root

  file { "/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    content => template('apache/awstats.erb'),
    require => [Package['apache'], Class['apache::awstats']],
  }

  $awstatsconf = $::operatingsystem ? {
    /RedHat|CentOS/ => 'puppet:///modules/apache/awstats.rh.conf',
    /Debian|Ubuntu/ => 'puppet:///modules/apache/awstats.deb.conf',
  }

  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  file { "${apache::params::root}/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => $awstatsconf,
    seltype => $confseltype,
    notify  => Exec['apache-graceful'],
    require => Apache::Vhost[$name],
  }
}
