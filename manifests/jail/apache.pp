class fail2ban::jail::apache (
  $maxretry = 'usedefault',
  $findtime = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default apache-auth filter from debian
  fail2ban::jail { 'apache':
    enabled  => 'true',
    port     => 'http,https',
    filter   => 'apache-auth',
    logpath  => '/var/log/apache*/*error.log',
    maxretry => $real_maxretry,
  }

  if $findtime != false {
    Fail2ban::Jail['apache'] {
      findtime => $findtime,
    }
  }

}
