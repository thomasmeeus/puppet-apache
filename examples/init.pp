#include apache
class { 'apache':
  apache_vhost_root => '/data/www',
}

apache::vhost { 'www.dummy.tld':
  ensure => present,
}

apache::proxypass { 'www.dummy.tld-legacy':
  ensure   => present,
  location => '/legacy/',
  url      => 'http://legacyserver.example.tld',
  params   => ['retry=5', 'ttl=120'],
  vhost    => 'www.dummy.tld',
}
