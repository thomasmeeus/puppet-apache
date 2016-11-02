define cegeka_apache::auth::htpasswd (
  $username,
  $ensure='present',
  $vhost=false,
  $userFileLocation=false,
  $userFileName='htpasswd',
  $cryptPassword=false,
  $clearPassword=false){

  include cegeka_apache::params

  if $userFileLocation {
    $_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $_userFileLocation = "${cegeka_apache::params::root}/${vhost}/private"
    } else {
      fail 'parameter vhost is required !'
    }
  }

  $_authUserFile = "${_userFileLocation}/${userFileName}"

  case $ensure {

    'present': {
      if $cryptPassword and $clearPassword {
        fail 'choose only one of cryptPassword OR clearPassword !'
      }

      if !$cryptPassword and !$clearPassword  {
        fail 'choose one of cryptPassword OR clearPassword !'
      }

      if $cryptPassword {
        exec {"/usr/bin/test -f ${_authUserFile} || OPT='-c'; ${cegeka_apache::params::htpasswd_cmd} -bp \${OPT} ${_authUserFile} ${username} '${cryptPassword}'":
          unless  => "/bin/grep -q \"${username}:${cryptPassword}\" ${_authUserFile}",
          require => File[$_userFileLocation],
        }
      }

      if $clearPassword {
        exec {"/usr/bin/test -f ${_authUserFile} || OPT='-c'; ${cegeka_apache::params::htpasswd_cmd} -bm \$OPT ${_authUserFile} ${username} '${clearPassword}'":
          unless  => "/bin/egrep \"^${username}:\" ${_authUserFile} && /bin/grep \"${username}:$(/bin/echo '${clearPassword}' | ${cegeka_apache::params::openssl_cmd} passwd -arp1 -salt $(/bin/egrep \"^${username}:\" ${_authUserFile} | cut -d'$' -f2))\" ${_authUserFile}",
          require => File[$_userFileLocation],
        }
      }
    }

    'absent': {
      exec {"${cegeka_apache::params::htpasswd_cmd} -D ${_authUserFile} ${username}":
        onlyif => "/bin/egrep -q '^${username}:' ${_authUserFile}",
        notify => Exec["delete ${_authUserFile} after remove ${username}"],
      }

      exec {"delete ${_authUserFile} after remove ${username}":
        command     => "/bin/rm -f ${_authUserFile}",
        onlyif      => "/usr/bin/wc -l ${_authUserFile} | /bin/egrep -q '^0[^0-9]'",
        refreshonly => true,
      }
    }
    default: {}
  }
}
