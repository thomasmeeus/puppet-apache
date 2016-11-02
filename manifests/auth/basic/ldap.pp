define cegeka_apache::auth::basic::ldap (
  $vhost,
  $authLDAPUrl,
  $ensure='present',
  $authname=false,
  $location='/',
  $authLDAPBindDN=false,
  $authLDAPBindPassword=false,
  $authLDAPCharsetConfig=false,
  $authLDAPCompareDNOnServer=false,
  $authLDAPDereferenceAliases=false,
  $authLDAPGroupAttribute=false,
  $authLDAPGroupAttributeIsDN=false,
  $authLDAPRemoteUserAttribute=false,
  $authLDAPRemoteUserIsDN=false,
  $authzLDAPAuthoritative=false,
  $authzRequire='valid-user'){

  $fname = regsubst($name, '\s', '_', 'G')

  include cegeka_apache::params

  if defined(Cegeka_apache::Module['ldap']) {} else {
    cegeka_apache::module {'ldap': }
  }

  if defined(Cegeka_apache::Module['authnz_ldap']) {} else {
    cegeka_apache::module {'authnz_ldap': }
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

  file { "${cegeka_apache::params::root}/${vhost}/conf/auth-basic-ldap-${fname}.conf":
    ensure  => $ensure,
    content => template('cegeka_apache/auth-basic-ldap.erb'),
    seltype => $confseltype,
    notify  => Exec['apache-graceful'],
  }

}
