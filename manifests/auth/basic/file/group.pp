define cegeka_apache::auth::basic::file::group (
  $vhost,
  $groups,
  $ensure='present',
  $authname=false,
  $location='/',
  $authUserFile=false,
  $authGroupFile=false){

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

  if $authGroupFile {
    $_authGroupFile = $authGroupFile
  } else {
    $_authGroupFile = "${cegeka_apache::params::root}/${vhost}/private/htgroup"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }
  $confseltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  file { "${cegeka_apache::params::root}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure  => $ensure,
    content => template('cegeka_apache/auth-basic-file-group.erb'),
    seltype => $confseltype,
    notify  => Exec['cegeka_apache-graceful'],
  }

}
