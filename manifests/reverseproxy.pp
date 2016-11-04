class cegeka_apache::reverseproxy {

  include cegeka_apache::params

  cegeka_apache::module {['proxy', 'proxy_http', 'proxy_ajp', 'proxy_connect']: }

  file { 'reverseproxy.conf':
    ensure  => present,
    path    => "${cegeka_apache::params::conf}/conf.d/reverseproxy.conf",
    content => '# file managed by puppet
<IfModule mod_proxy.c>
  ProxyRequests Off
  <Proxy *>
    Order Deny,Allow
    Deny from all
  </Proxy>
</IfModule>
',
    notify  => Exec['cegeka_apache-graceful'],
    require => Package['cegeka_apache'],
  }

}
