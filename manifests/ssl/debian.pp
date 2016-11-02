class cegeka_apache::ssl::debian {
  include cegeka_apache::base::ssl

  cegeka_apache::module {'ssl':
    ensure => present,
  }

  if !defined(Package['ca-certificates']) {
    package { 'ca-certificates':
      ensure => present,
    }
  }
}
