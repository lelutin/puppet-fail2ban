class fail2ban::config {

  if $::operatingsystem == 'gentoo' {
    file { '/etc/conf.d/fail2ban':
      ensure => present,
      source => [
        "puppet:///modules/site_fail2ban/conf.d/${::fqdn}/fail2ban",
        'puppet:///modules/site_fail2ban/conf.d/fail2ban',
        'puppet:///modules/fail2ban/conf.d/fail2ban'
      ],
      owner => 'root',
      group => 0,
      mode  => '0644';
    }
  }

}
