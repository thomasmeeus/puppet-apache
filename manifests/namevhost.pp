/*
== Definition: cegeka_apache::namevhost

Adds a "NameVirtualHost" directive to apache's port.conf file.

Every "ports" parameter you define Cegeka_apache::Vhost resources should have a
matching NameVirtualHost directive.

Parameters:
- *ensure*: present/absent.
- *name*: ipaddress or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  cegeka_apache::namevhost { "*:80": }
  cegeka_apache::namevhost { "127.0.0.1:8080": ensure => present }

*/
define cegeka_apache::namevhost ($ensure='present') {

  include cegeka_apache::params

  concat::fragment { "apache-namevhost.conf-${name}":
    target  => "${cegeka_apache::params::conf}/ports.conf",
    content => "NameVirtualHost ${name}\n",
  }

}
