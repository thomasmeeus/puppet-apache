define cegeka_apache::auth::htgroup (
  $groupname,
  $members,
  $ensure='present',
  $vhost=false,
  $groupFileLocation=false,
  $groupFileName='htgroup'){

  include cegeka_apache::params

  if $groupFileLocation {
    $_groupFileLocation = $groupFileLocation
  } else {
    if $vhost {
      $_groupFileLocation = "${cegeka_apache::params::root}/${vhost}/private"
    } else {
      fail 'parameter vhost is require !'
    }
  }

  $_authGroupFile = "${_groupFileLocation}/${groupFileName}"

  case $ensure {

    'present': {
      exec {"/usr/bin/test -f ${_authGroupFile} || OPT='-c'; ${cegeka_apache::params::htpasswd_cmd} \$OPT ${_authGroupFile} ${groupname} ${members}":
        unless  => "/bin/egrep -q '^${groupname}: ${members}$' ${_authGroupFile}",
        require => File[$_groupFileLocation],
      }
    }

    'absent': {
      exec {"${cegeka_apache::params::htpasswd_cmd} -D ${_authGroupFile} ${groupname}":
        onlyif => "/bin/egrep -q '^${groupname}:' ${_authGroupFile}",
        notify => Exec["delete ${_authGroupFile} after remove ${groupname}"],
      }

      exec {"delete ${_authGroupFile} after remove ${groupname}":
        command     => "/bin/rm -f ${_authGroupFile}",
        onlyif      => "/usr/bin/wc -l ${_authGroupFile} | /bin/egrep -q '^0[^0-9]'",
        refreshonly => true,
      }
    }
    default: {}
  }
}
