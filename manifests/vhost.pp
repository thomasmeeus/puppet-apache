define apache::vhost (
  $ensure=present,
  $config_file='',
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=true,
  $user='',
  $admin='',
  $group='',
  $mode=2570,
  $aliases=[],
  $ports=['*:80'],
  $accesslog_format='combined'
) {

  include apache::params

  $wwwuser = $user ? {
    ''      => $apache::params::user,
    default => $user,
  }

  $wwwgroup = $group ? {
    ''      => $apache::params::group,
    default => $group,
  }

  # used in ERB templates
  $wwwroot = $apache::params::root

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
      file { "${apache::params::conf}/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        seltype => $configseltype,
        require => Package[$apache::params::pkg],
        notify  => Exec['apache-graceful'],
      }

      $sysseltype = $::operatingsystem ? {
        RedHat  => 'httpd_sys_content_t',
        CentOS  => 'httpd_sys_content_t',
        default => undef,
      }
      file { "${apache::params::root}/${name}":
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
      file { "${apache::params::root}/${name}/conf":
        ensure    => directory,
        group     => $wwwgroup,
        mode      => $mode,
        owner     => $owner,
        seltype   => $configseltype,
        require   => [File["${apache::params::root}/${name}"]],
      }

      file { "${apache::params::root}/${name}/htdocs":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $sysseltype,
        require => [File["${apache::params::root}/${name}"]],
      }

      if $htdocs {
        File["${apache::params::root}/${name}/htdocs"] {
          source  => $htdocs,
          recurse => true,
        }
      }

      if $conf {
        File["${apache::params::root}/${name}/conf"] {
          source  => $conf,
          recurse => true,
        }
      }

      # cgi-bin
      $real_cgipath = $cgipath ? {
          false   => "${apache::params::root}/${name}/cgi-bin/",
          default => $cgipath,
      }
      $real_ensurecgi = $cgipath ? {
        "${apache::params::root}/${name}/cgi-bin/"  => directory,
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
        require => [File["${apache::params::root}/${name}"]],
      }

      case $config_file {

        default: {
          File["${apache::params::conf}/sites-available/${name}"] {
            source => $config_file,
          }
        }
        '': {

          if $config_content {
            File["${apache::params::conf}/sites-available/${name}"] {
              content => $config_content,
            }
          } else {
            # default vhost template
            File["${apache::params::conf}/sites-available/${name}"] {
              content => template('apache/vhost.erb'),
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
      file {"${apache::params::root}/${name}/logs":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $logseltype,
        require => File["${apache::params::root}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${apache::params::root}/${name}/logs/access.log",
              "${apache::params::root}/${name}/logs/error.log"] :
        ensure  => present,
        owner   => root,
        group   => adm,
        mode    => '0644',
        seltype => $logseltype,
        require => File["${apache::params::root}/${name}/logs"],
      }

      # Private data
      file {"${apache::params::root}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $sysseltype,
        require => File["${apache::params::root}/${name}"],
      }

      # README file
      $readme_content = $readme ? {
        false   => template('apache/README_vhost.erb'),
        default => $readme,
      }
      file {"${apache::params::root}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => $readme_content,
        require => File["${apache::params::root}/${name}"],
      }


      exec {"enable vhost ${name}":
        command => "${apache::params::a2ensite} ${name}",
        notify  => Exec['apache-graceful'],
        require => [File[$apache::params::a2ensite],
          File["${apache::params::conf}/sites-available/${name}"],
          File["${apache::params::root}/${name}/htdocs"],
          File["${apache::params::root}/${name}/logs"],
          File["${apache::params::root}/${name}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
    }

    absent:{
      file { "${apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      file { "${apache::params::conf}/sites-available/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      exec { "remove ${apache::params::root}/${name}":
        command => "/bin/rm -rf ${apache::params::root}/${name}",
        onlyif  => "/usr/bin/test -d ${apache::params::root}/${name}",
        require => Exec["disable vhost ${name}"],
      }

      exec { "disable vhost ${name}":
        command => "${apache::params::a2dissite} ${name}",
        notify  => Exec['apache-graceful'],
        require => File[$apache::params::a2ensite],
        onlyif  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
  }

  disabled: {
      $disablecmd = $::operatingsystem ? {
          RedHat  => "/usr/local/sbin/a2dissite ${name}",
          CentOS  => "/usr/local/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}",
      }
      exec { "disable vhost ${name}":
        require => Package[$apache::params::pkg],
        notify  => Exec['apache-graceful'],
        command => "${apache::params::a2dissite} ${name}",
        onlyif  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }

      file { "${apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { fail ( "Unknown ensure value: '${ensure}'" ) }
  }
}
