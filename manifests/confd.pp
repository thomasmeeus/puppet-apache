/*

== Definition: cegeka_apache::confd

Convenient wrapper around cegeka_apache::conf definition to put configuration snippets in
${cegeka_apache::params::conf}/conf.d directory

Parameters:
- *ensure*: present/absent.
- *configuration*: apache configuration(s) to be applied
- *filename*: basename of the file in which the configuration(s) will be put.
  Useful in the case configuration order matters: apache reads the files in conf.d/
  in alphabetical order.

Requires:
- Class['cegeka_apache']

Example usage:

  cegeka_apache::confd { 'example 1':
    ensure        => present,
    configuration => 'WSGIPythonEggs /var/cache/python-eggs',
  }

*/
define cegeka_apache::confd($configuration, $ensure=present, $filename='') {
  include cegeka_apache::params
  cegeka_apache::conf {$name:
    ensure        => $ensure,
    path          => "${cegeka_apache::params::conf}/conf.d",
    filename      => $filename,
    configuration => $configuration,
    notify        => Service['cegeka_apache'],
  }
}
