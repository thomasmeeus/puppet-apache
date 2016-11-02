define cegeka_apache::aw-stats($ensure=present, $aliases=[]) {

  include cegeka_apache::params

  # used in ERB template
  $wwwroot = $cegeka_apache::params::root

  file { "/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    content => template('cegeka_apache/awstats.erb'),
    require => [Package['cegeka_apache'], Class['cegeka_apache::awstats']],
  }

  $awstatsconf = $::operatingsystem ? {
    /RedHat|CentOS/ => 'puppet:///modules/cegeka_apache/awstats.rh.conf',
    /Debian|Ubuntu/ => 'puppet:///modules/cegeka_apache/awstats.deb.conf',
  }

  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  file { "${cegeka_apache::params::root}/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => $awstatsconf,
    seltype => $confseltype,
    notify  => Exec['apache-graceful'],
    require => Cegeka_apache::Vhost[$name],
  }
}
