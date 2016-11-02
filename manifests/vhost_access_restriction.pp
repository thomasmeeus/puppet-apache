/*

== Definition: cegeka_apache::vhost-access-restriction

Simple way of restriction the access to a folder in a given virtualhost.

This definition will ensure all the required modules are loaded and will
drop a configuration snippet in the virtualhost's conf/ directory.

Parameters:
- *ensure*: present/absent.
- *location*: path in virtualhost's context to pass through using the ProxyPass
  directive.
- *url*: destination to which the ProxyPass directive points to.
- *params*: a table of key=value (min, max, timeout, retry, etc.) described
  in the ProxyPass Directive documentation http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.
- *sslbackend*: define wether the module should enable proxy ssl backends
- *proxy_config*: addition proxy configuration like ProxyPreserveHost, ..

Requires:
- Class["apache"]
- matching Cegeka_apache::Vhost[] instance

Example usage:

  cegeka_apache::proxypass { "proxy legacy dir to legacy server":
    ensure       => present,
    location     => "/legacy/",
    url          => "http://legacyserver.example.com",
    params       => ["retry=5", "ttl=120"],
    vhost        => "www.example.com",
    proxy_config => ['ProxyPreserveHost On']
  }

*/
define cegeka_apache::vhost_access_restriction (
  $vhost=namevar,
  $ensure='present',
  $folder,
  $options='FollowSymLinks',
  $order='Deny,Allow',
  $deny_from = ['all'],
  $allow_from = [],
) {

  include cegeka_apache::params


  file { "access restriction on ${name} on ${vhost}":
    ensure  => $ensure,
    content => template('cegeka_apache/vhost_access_restriction.erb'),
    path    => "${cegeka_apache::params::root}/${vhost}/conf/00-vhost_access_restriction-${name}.conf",
    notify  => Exec['apache-graceful'],
    require => Cegeka_apache::Vhost[$vhost],
  }
}
