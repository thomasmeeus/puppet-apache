/*

== Definition: cegeka_apache::redirectmatch

Convenient way to declare a RedirectMatch directive in a virtualhost context.

Parameters:
- *ensure*: present/absent.
- *regex*: regular expression matching the part of the URL which should get
  redirected. Mandatory.
- *url*: destination URL the redirection should point to. Mandatory.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class["apache"]
- matching Cegeka_apache::Vhost[] instance

Example usage:

  cegeka_apache::redirectmatch { "example":
    regex => "^/(foo|bar)",
    url   => "http://foobar.example.com/",
    vhost => "www.example.com",
  }

*/
define cegeka_apache::redirectmatch (
  $regex,
  $url,
  $vhost,
  $ensure='present',
  $filename=''
) {

  $fname = regsubst($name, '\s', '_', 'G')

  include cegeka_apache::params

  $confseltype =  $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  $real_conf_path = $filename ? {
    ''      => "${cegeka_apache::params::root}/${vhost}/conf/redirect-${fname}.conf",
    default => "${cegeka_apache::params::root}/${vhost}/conf/${filename}",
  }

  file { "${name} redirect on ${vhost}":
    ensure  => $ensure,
    content => "# file managed by puppet\nRedirectMatch ${regex} ${url}\n",
    seltype => $confseltype,
    path    => $real_conf_path,
    notify  => Exec['cegeka_apache-graceful'],
    require => Cegeka_apache::Vhost[$vhost],
  }
}
