include apache

apache::vhost { 'www.dummy.tld':
  ensure => present,
}

apache::proxypass { 'www.dummy.tld/dummy':
  ensure   => present,
  location => '/legacy/',
  url      => 'http://legacyserver.example.tld',
  params   => ['retry=5', 'ttl=120'],
  vhost    => 'www.dummy.tld',
}
