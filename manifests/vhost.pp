define cegeka_apache::vhost (
  $ensure=present,
  $config_file='',
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=false,
  $user='',
  $admin='',
  $group='',
  $mode=2570,
  $aliases=[],
  $ports=['*:80'],
  $accesslog_format='combined',
  $enablehsts=false
) {

  include cegeka_apache::params

  $wwwuser = $user ? {
    ''      => $cegeka_apache::params::user,
    default => $user,
  }

  $wwwgroup = $group ? {
    ''      => $cegeka_apache::params::group,
    default => $group,
  }

  # used in ERB templates
  $wwwroot = $cegeka_apache::params::root

  $documentroot = $docroot ? {
    false   => "${wwwroot}/${name}/htdocs",
    default => $docroot,
  }

  $cgipath = $cgibin ? {
    true    => "${wwwroot}/${name}/cgi-bin/",
    false   => false,
    default => $cgibin,
  }

  case $ensure {
    present: {
      $enablecmd = $::operatingsystem ? {
        'RedHat'  => "/usr/local/sbin/a2ensite ${name}",
        'CentOS'  => "/usr/local/sbin/a2ensite ${name}",
        default   => "/usr/sbin/a2ensite ${name}",
      }
      $configseltype = $::operatingsystem ? {
        RedHat  => 'httpd_config_t',
        CentOS  => 'httpd_config_t',
        default => undef,
      }
      file { "${cegeka_apache::params::conf}/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        seltype => $configseltype,
        require => Package[$cegeka_apache::params::pkg],
        notify  => Exec['cegeka_apache-graceful'],
      }

      $sysseltype = $::operatingsystem ? {
        RedHat  => 'httpd_sys_content_t',
        CentOS  => 'httpd_sys_content_t',
        default => undef,
      }
      file { "${cegeka_apache::params::root}/${name}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $sysseltype,
        require => File['root directory'],
      }

      $owner = $admin ? {
        ''      => $wwwuser,
        default => $admin,
      }
      file { "${cegeka_apache::params::root}/${name}/conf":
        ensure    => directory,
        group     => $wwwgroup,
        mode      => $mode,
        owner     => $owner,
        seltype   => $configseltype,
        require   => [File["${cegeka_apache::params::root}/${name}"]],
      }

      file { "${cegeka_apache::params::root}/${name}/htdocs":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $sysseltype,
        require => [File["${cegeka_apache::params::root}/${name}"]],
      }

      if $htdocs {
        File["${cegeka_apache::params::root}/${name}/htdocs"] {
          source  => $htdocs,
          recurse => true,
        }
      }

      if $conf {
        File["${cegeka_apache::params::root}/${name}/conf"] {
          source  => $conf,
          recurse => true,
        }
      }

      # cgi-bin
      $real_cgipath = $cgipath ? {
          false   => "${cegeka_apache::params::root}/${name}/cgi-bin/",
          default => $cgipath,
      }
      $real_ensurecgi = $cgipath ? {
        "${cegeka_apache::params::root}/${name}/cgi-bin/"  => directory,
        default                                     => undef,
      }

      $scriptseltype = $::operatingsystem ? {
        RedHat  => 'httpd_sys_script_exec_t',
        CentOS  => 'httpd_sys_script_exec_t',
        default => undef,
      }

      file { "${name} cgi-bin directory":
        ensure  => $real_ensurecgi,
        path    => $real_cgipath,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $scriptseltype,
        require => [File["${cegeka_apache::params::root}/${name}"]],
      }

      case $config_file {

        default: {
          File["${cegeka_apache::params::conf}/sites-available/${name}"] {
            source => $config_file,
          }
        }
        '': {

          if $config_content {
            File["${cegeka_apache::params::conf}/sites-available/${name}"] {
              content => $config_content,
            }
          } else {
            # default vhost template
            File["${cegeka_apache::params::conf}/sites-available/${name}"] {
              content => template('cegeka_apache/vhost.erb'),
            }
          }
        }
      }

      # Log files
      $logseltype = $::operatingsystem ? {
        RedHat  => 'httpd_log_t',
        CentOS  => 'httpd_log_t',
        default => undef,
      }
      file {"${cegeka_apache::params::root}/${name}/logs":
        ensure  => directory,
        owner   => apache,
        group   => apache,
        mode    => '0755',
        seltype => $logseltype,
        require => File["${cegeka_apache::params::root}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${cegeka_apache::params::root}/${name}/logs/access.log",
              "${cegeka_apache::params::root}/${name}/logs/error.log"] :
        ensure  => present,
        owner   => apache,
        group   => apache,
        mode    => '0644',
        seltype => $logseltype,
        require => File["${cegeka_apache::params::root}/${name}/logs"],
      }

      # Private data
      file {"${cegeka_apache::params::root}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $sysseltype,
        require => File["${cegeka_apache::params::root}/${name}"],
      }

      # README file
      $readme_content = $readme ? {
        false   => template('cegeka_apache/README_vhost.erb'),
        default => $readme,
      }
      file {"${cegeka_apache::params::root}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => $readme_content,
        require => File["${cegeka_apache::params::root}/${name}"],
      }


      exec {"enable vhost ${name}":
        command => "${cegeka_apache::params::a2ensite} ${name}",
        notify  => Exec['cegeka_apache-graceful'],
        require => [File[$cegeka_apache::params::a2ensite],
          File["${cegeka_apache::params::conf}/sites-available/${name}"],
          File["${cegeka_apache::params::root}/${name}/htdocs"],
          File["${cegeka_apache::params::root}/${name}/logs"],
          File["${cegeka_apache::params::root}/${name}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L ${cegeka_apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${cegeka_apache::params::conf}/sites-enabled/${name} -ef ${cegeka_apache::params::conf}/sites-available/${name} ]'",
      }
    }

    absent:{
      file { "${cegeka_apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      file { "${cegeka_apache::params::conf}/sites-available/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      exec { "remove ${cegeka_apache::params::root}/${name}":
        command => "/bin/rm -rf ${cegeka_apache::params::root}/${name}",
        onlyif  => "/usr/bin/test -d ${cegeka_apache::params::root}/${name}",
        require => Exec["disable vhost ${name}"],
      }

      exec { "disable vhost ${name}":
        command => "${cegeka_apache::params::a2dissite} ${name}",
        notify  => Exec['cegeka_apache-graceful'],
        require => File[$cegeka_apache::params::a2ensite],
        onlyif  => "/bin/sh -c '[ -L ${cegeka_apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${cegeka_apache::params::conf}/sites-enabled/${name} -ef ${cegeka_apache::params::conf}/sites-available/${name} ]'",
      }
  }

  disabled: {
      $disablecmd = $::operatingsystem ? {
          RedHat  => "/usr/local/sbin/a2dissite ${name}",
          CentOS  => "/usr/local/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}",
      }
      exec { "disable vhost ${name}":
        require => Package[$cegeka_apache::params::pkg],
        notify  => Exec['cegeka_apache-graceful'],
        command => "${cegeka_apache::params::a2dissite} ${name}",
        onlyif  => "/bin/sh -c '[ -L ${cegeka_apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${cegeka_apache::params::conf}/sites-enabled/${name} -ef ${cegeka_apache::params::conf}/sites-available/${name} ]'",
      }

      file { "${cegeka_apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { fail ( "Unknown ensure value: '${ensure}'" ) }
  }
}
