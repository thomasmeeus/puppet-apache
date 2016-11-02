class cegeka_apache::params {

  $pkg = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
  }

  $root = $cegeka_apache::apache_vhost_root ? {
    ''      => $::operatingsystem ? {
      /RedHat|CentOS/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
    },
    default => $cegeka_apache::apache_vhost_root
  }

  $service_status = $cegeka_apache::ensure_status ? {
    ''      => 'running',
    default => $cegeka_apache::ensure_status
  }

  $default_port = $cegeka_apache::default_port ? {
    ''      => '80',
    default => $cegeka_apache::default_port,
  }

  $user = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
  }

  $group = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
  }

  $conf = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
  }

  $log = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
  }

  $access_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
  }

  $a2ensite = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/local/sbin/a2ensite',
    /Debian|Ubuntu/ => '/usr/sbin/a2ensite',
  }

  $a2dissite = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/local/sbin/a2dissite',
    /Debian|Ubuntu/ => '/usr/sbin/a2dissite',
  }

  $error_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
  }

  $logrotate_paths = "${cegeka_apache::params::root}/*/logs/*.log ${cegeka_apache::params::log}/*log"
  $httpd_pid_file = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd/run/httpd.pid',
    /Debian|Ubuntu/ => '/etc/httpd/run/httpd.pid',
  }
  $httpd_reload_cmd = $::operatingsystem ? {
    /RedHat|CentOS/ => '/sbin/service httpd graceful > /dev/null 2> /dev/null || true',
    /Debian|Ubuntu/ => '/etc/init.d/apache2 restart > /dev/null',
  }
  $htpasswd_cmd = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/bin/htpasswd',
    /Debian|Ubuntu/ => '/usr/bin/htpasswd',
  }
  $htgroup_cmd = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/local/bin/htgroup',
    /Debian|Ubuntu/ => '/usr/local/bin/htgroup',
  }
  $openssl_cmd = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/bin/openssl',
    /Debian|Ubuntu/ => '/usr/bin/openssl',
  }
  $awstats_condition = $::operatingsystem ? {
    /RedHat|CentOS/ => '-x /etc/cron.hourly/awstats',
    /Debian|Ubuntu/ => '-f /usr/share/doc/awstats/examples/awstats_updateall.pl -a -f /usr/lib/cgi-bin/awstats.pl',
  }
  $awstats_command = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/cron.hourly/awstats || true',
    /Debian|Ubuntu/ => '/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null',
  }

  $apache_disable_default_vhost = false
}
