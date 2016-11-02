class cegeka_apache::redhat {
  include cegeka_apache::base
  include cegeka_apache::params

  file {[
    '/usr/local/sbin/a2ensite',
    '/usr/local/sbin/a2dissite',
    '/usr/local/sbin/a2enmod',
    '/usr/local/sbin/a2dismod'
  ]:
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/cegeka_apache/usr/local/sbin/a2X.redhat',
  }

  $httpd_mpm = $cegeka_apache::apache_mpm_type ? {
    ''         => 'httpd', # default MPM
    'pre-fork' => 'httpd',
    'prefork'  => 'httpd',
    default    => "httpd.${cegeka_apache::apache_mpm_type}",
  }

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/${httpd_mpm}",
    require => Package['cegeka_apache'],
    notify  => Service['cegeka_apache'],
  }

  file { [
      "${cegeka_apache::params::conf}/sites-available",
      "${cegeka_apache::params::conf}/sites-enabled",
      "${cegeka_apache::params::conf}/mods-enabled"
    ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['cegeka_apache'],
  }

  $real_httpd_source = $::operatingsystemrelease ? {
    /5.*/ => 'cegeka_apache/httpd-2.2.conf.erb',
    /6.*/ => 'cegeka_apache/httpd-2.2.conf.erb',
    /7.*/ => 'cegeka_apache/httpd-2.4.conf.erb'
  }

  file { "${cegeka_apache::params::conf}/conf/httpd.conf":
    ensure  => present,
    content => template($real_httpd_source),
    seltype => 'httpd_config_t',
    notify  => Service['cegeka_apache'],
    require => Package['cegeka_apache'],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  $real_module_source = $::operatingsystemrelease ? {
    /5.*/ => 'puppet:///modules/cegeka_apache/etc/httpd/mods-available/redhat5/',
    /6.*/ => 'puppet:///modules/cegeka_apache/etc/httpd/mods-available/redhat6/',
    /7.*/ => 'puppet:///modules/cegeka_apache/etc/httpd/mods-available/redhat7/',
  }

  file { "${cegeka_apache::params::conf}/mods-available":
    ensure  => directory,
    source  => $real_module_source,
    recurse => true,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['cegeka_apache'],
  }

  # this module is statically compiled on debian and must be enabled here
  cegeka_apache::module {'log_config':
    ensure => present,
    notify => Exec['apache-graceful'],
  }

  # it makes no sens to put CGI here, deleted from the default vhost config
  file {'/var/www/cgi-bin':
    ensure  => absent,
    force   => true,
    recurse => true,
    require => Package['cegeka_apache'],
  }

  # no idea why redhat choose to put this file there. apache fails if it's
  # present and mod_proxy isn't...
  file { "${cegeka_apache::params::conf}/conf.d/proxy_ajp.conf":
    ensure  => absent,
    require => Package['cegeka_apache'],
    notify  => Exec['apache-graceful'],
  }

}

