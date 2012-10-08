class apache::ssl::debian {
  include apache::base::ssl

  apache::module {'ssl':
    ensure => present,
  }

  if !defined(Package['ca-certificates']) {
    package { 'ca-certificates':
      ensure => present,
    }
  }
}
