/*
== Definition: cegeka_apache::listen

Adds a "Listen" directive to apache's port.conf file.

Parameters:
- *ensure*: present/absent.
- *name*: port number, or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  cegeka_apache::listen { "80": }
  cegeka_apache::listen { "127.0.0.1:8080": ensure => present }

*/
define cegeka_apache::listen ($ensure='present') {

  include cegeka_apache::params

  concat::fragment { "apache-ports.conf-${name}":
    target  => "${cegeka_apache::params::conf}/ports.conf",
    content => "Listen ${name}\n",
  }

}
