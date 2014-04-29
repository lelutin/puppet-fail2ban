class fail2ban::jail::xinetd_fail (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
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
    findtime  => $findtime,
    ignoreip  => $ignoreip,
  }

}
