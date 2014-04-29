class fail2ban::jail::xinetd_fail (
  $maxretry = 'usedefault',
  $findtime = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '2',
    default      => $maxretry
  }

  # Use default xinetd-fail filter from debian
  fail2ban::jail { 'xinetd_fail':
    enabled   => 'true',
    port      => 'all',
    filter    => 'xinetd-fail',
    banaction => 'iptables-multiport-log',
    logpath   => '/var/log/auth.log',
    maxretry  => $real_maxretry,
  }

  if $findtime != false {
    Fail2ban::Jail['xinetd_fail'] {
      findtime => $findtime,
    }
  }

}
