class cegeka_apache::ssl::redhat {
  include cegeka_apache::base::ssl

  package {'mod_ssl':
    ensure => installed,
  }

  file {'/etc/httpd/ssl':
    ensure  => directory,
    mode    => '0440',
    require => Package['mod_ssl']
  }

  file {'/etc/httpd/conf.d/ssl.conf':
    ensure  => absent,
    require => Package['mod_ssl'],
    notify  => Service['cegeka_apache'],
    before  => Exec['cegeka_apache-graceful'],
  }

  cegeka_apache::module { 'ssl':
    ensure  => present,
    require => File['/etc/httpd/conf.d/ssl.conf'],
    notify  => Service['cegeka_apache'],
    before  => Exec['cegeka_apache-graceful'],
  }

  case $::operatingsystemrelease{
    /5.*|6.*/: {
      file {'/etc/httpd/mods-available/ssl.load':
        ensure  => present,
        content => template('cegeka_apache/ssl.load.rhel5.erb'),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        seltype => 'httpd_config_t',
        require => File['/etc/httpd/mods-available'],
      }
    }
    /7.*/: {
      file {'/etc/httpd/mods-available/ssl.load':
        ensure  => present,
        content => template('cegeka_apache/ssl.load.rhel7.erb'),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        seltype => 'httpd_config_t',
        require => File['/etc/httpd/mods-available'],
      }
    }
    default: {}
  }
}
