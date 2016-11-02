/*

== Definition: cegeka_apache::proxypass

Simple way of defining a proxypass directive for a given virtualhost.

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
define cegeka_apache::proxypass (
  $vhost,
  $ensure='present',
  $location='',
  $url='',
  $params=[],
  $filename='',
  $sslbackend=false,
  $proxy_config=[]
) {

  $fname = regsubst($name, '\s', '_', 'G')

  include cegeka_apache::params

  if defined(Cegeka_apache::Module['proxy']) {} else {
    cegeka_apache::module {'proxy':
    }
  }

  if defined(Cegeka_apache::Module['proxy_http']) {} else {
    cegeka_apache::module {'proxy_http':
    }
  }

  if ($sslbackend) {
    if defined(Cegeka_apache::Module['ssl']) {} else {
      cegeka_apache::module {'ssl':
      }
    }
  }

  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  $proxypassconfig = $filename ? {
    ''      => "${cegeka_apache::params::root}/${vhost}/conf/proxypass-${fname}.conf",
    default => "${cegeka_apache::params::root}/${vhost}/conf/${filename}",
  }

  file { "${name} proxypass on ${vhost}":
    ensure  => $ensure,
    content => template('cegeka_apache/proxypass.erb'),
    seltype => $confseltype,
    path    => $proxypassconfig,
    notify  => Exec['apache-graceful'],
    require => Cegeka_apache::Vhost[$vhost],
  }
}
