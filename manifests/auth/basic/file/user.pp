define cegeka_apache::auth::basic::file::user (
  $vhost,
  $ensure='present',
  $authname=false,
  $location='/',
  $authUserFile=false,
  $users='valid-user'){

  $fname = regsubst($name, '\s', '_', 'G')

  include cegeka_apache::params

  if defined(Cegeka_apache::Module['authn_file']) {} else {
    cegeka_apache::module {'authn_file': }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${cegeka_apache::params::root}/${vhost}/private/htpasswd"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  if $users != 'valid-user' {
    $_users = "user ${users}"
  } else {
    $_users = $users
  }

  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  file {"${cegeka_apache::params::root}/${vhost}/conf/auth-basic-file-user-${fname}.conf":
    ensure  => $ensure,
    content => template('cegeka_apache/auth-basic-file-user.erb'),
    seltype => $confseltype,
    notify  => Exec['apache-graceful'],
  }

}
