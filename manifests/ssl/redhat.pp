class apache::ssl::redhat {
  include apache::base::ssl

  package {'mod_ssl':
    ensure => installed,
  }

  file {'/etc/httpd/conf.d/ssl.conf':
    ensure  => absent,
    require => Package['mod_ssl'],
    notify  => Service['apache'],
    before  => Exec['apache-graceful'],
  }

  apache::module { 'ssl':
    ensure  => present,
    require => File['/etc/httpd/conf.d/ssl.conf'],
    notify  => Service['apache'],
    before  => Exec['apache-graceful'],
  }

  case $::operatingsystemrelease{
    /5.*|6.*/: {
      file {'/etc/httpd/mods-available/ssl.load':
        ensure  => present,
        content => template('apache/ssl.load.rhel5.erb'),
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
        content => template('apache/ssl.load.rhel7.erb'),
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
