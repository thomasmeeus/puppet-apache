class cegeka_apache::svnserver {
  include cegeka_apache::ssl

  case $::operatingsystem {

    Debian,Ubuntu:  {
      $pkglist = [ 'libapache2-svn' ]
    }

    RedHat,CentOS:  {
      $pkglist = [ 'mod_dav_svn' ]
    }

    default: {
      fail "Unsupported operatingsystem ${::operatingsystem}"
    }

  }

  package { $pkglist:
    ensure => present,
  }

  cegeka_apache::module { ['dav','dav_svn']:
    ensure  => present,
    require => Package[ $pkglist ],
  }

}
