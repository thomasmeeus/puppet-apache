class cegeka_apache::webdav::ssl {
  include cegeka_apache::ssl

  case $::operatingsystem {
    Debian,Ubuntu:  { include cegeka_apache::webdav::ssl::debian}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
