class cegeka_apache::webdav::base {

  case $::operatingsystem {

    Debian,Ubuntu:  {

      package {'libapache2-mod-encoding':
        ensure => present,
      }

      cegeka_apache::module {'encoding':
        ensure  => present,
        require => Package['libapache2-mod-encoding'],
      }

    /* Other OS: If you encounter issue with encoding, read the description of
        the Debian package:
        http://packages.debian.org/squeeze/libapache2-mod-encoding
    */

    }
    default: {}
  }

  cegeka_apache::module {['dav', 'dav_fs']:
    ensure => present,
  }

  if !defined(Cegeka_apache::Module['headers']) {
    cegeka_apache::module {'headers':
      ensure => present,
    }
  }

}
