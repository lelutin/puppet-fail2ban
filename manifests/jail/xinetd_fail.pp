class fail2ban::jail::xinetd_fail {

  # Use default xinetd-fail filter from debian
  fail2ban::jail { 'xinetd_fail':
    enabled   => 'true',
    port      => 'all',
    filter    => 'xinetd-fail',
    banaction => 'iptables-multiport-log',
    logpath   => '/var/log/auth.log',
    maxretry  => '2',
  }

}
