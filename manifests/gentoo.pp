class fail2ban::gentoo inherits fail2ban::base {
  Package['fail2ban']{
    category => 'net-analyzer',
  }
  file { "/etc/conf.d/fail2ban":
    ensure => present,
    source => [
      "puppet:///modules/site_fail2ban/conf.d/${::fqdn}/fail2ban",
      "puppet:///modules/site_fail2ban/conf.d/fail2ban",
      "puppet:///modules/fail2ban/conf.d/fail2ban"
    ],
    require => Package['fail2ban'],
    notify => Service['fail2ban'],
    owner => root, group => 0, mode  => 0644;
  }
}
