class cegeka_apache::deflate {

  include cegeka_apache::params

  cegeka_apache::module {'deflate':
    ensure => present,
  }

  file { 'deflate.conf':
    ensure  => present,
    path    => "${cegeka_apache::params::conf}/conf.d/deflate.conf",
    content => '# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript text/css
  BrowserMatch Safari/4 no-gzip
</IfModule>
',
    notify  => Exec['cegeka_apache-graceful'],
    require => Package['cegeka_apache'],
  }

}
