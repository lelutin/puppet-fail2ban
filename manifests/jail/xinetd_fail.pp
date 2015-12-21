class fail2ban::jail::xinetd_fail (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '2',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/auth.log',
    'RedHat' => '%(syslog_daemon)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default xinetd-fail filter
  fail2ban::jail { 'xinetd_fail':
    enabled   => true,
    port      => 'all',
    filter    => 'xinetd-fail',
    banaction => 'iptables-multiport-log',
    logpath   => $logpath,
    maxretry  => $real_maxretry,
    findtime  => $findtime,
    ignoreip  => $ignoreip,
  }

}
