/*

== Class: cegeka_apache::base::ssl

Common building blocks between cegeka_apache::ssl::debian and cegeka_apache::ssl::redhat.

It shouldn't be necessary to directly include this class.

*/
class cegeka_apache::base::ssl {

  cegeka_apache::listen { '443':
    ensure => present
  }

  if ($::operatingsystemmajrelease < 7) {
    cegeka_apache::namevhost { '*:443':
      ensure => present
    }
  }

  file { '/usr/local/sbin/generate-ssl-cert.sh':
    source => 'puppet:///modules/cegeka_apache/generate-ssl-cert.sh',
    mode   => '0755',
  }

}
