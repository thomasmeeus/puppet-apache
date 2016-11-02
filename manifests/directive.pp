/*

== Definition: cegeka_apache::directive

Convenient wrapper around cegeka_apache::conf resources to add random configuration
snippets to an apache virtualhost.

Parameters:
- *ensure*: present/absent.
- *directive*: apache directive(s) to be applied in the corresponding
  <VirtualHost> section.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class['cegeka_apache']
- matching Cegeka_apache::Vhost[] instance

Example usage:

  cegeka_apache::directive { 'example 1':
    ensure    => present,
    directive => '
      RewriteEngine on
      RewriteRule ^/?$ https://www.example.com/
    ',
    vhost     => 'www.example.com',
  }

  cegeka_apache::directive { 'example 2':
    ensure    => present,
    directive => content('example/snippet.erb'),
    vhost     => 'www.example.com',
  }

*/
define cegeka_apache::directive ($vhost, $ensure=present, $directive='', $filename='') {

  include cegeka_apache::params

  if ($ensure == present and $directive == '') {
    fail 'empty "directive" parameter'
  }

  cegeka_apache::conf {$name:
    ensure        => $ensure,
    path          => "${cegeka_apache::params::root}/${vhost}/conf",
    prefix        => 'directive',
    filename      => $filename,
    configuration => $directive,
    require       => Cegeka_apache::Vhost[$vhost],
  }
}
