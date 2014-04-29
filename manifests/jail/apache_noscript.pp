class fail2ban::jail::apache_noscript (
  $maxretry = 'usedefault',
  $findtime = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default apache-noscript filter from debian
  fail2ban::jail { 'apache-noscript':
    enabled  => 'true',
    port     => 'http,https',
    filter   => 'apache-noscript',
    logpath  => '/var/log/apache*/*error.log',
    maxretry => $real_maxretry,
  }

  if $findtime != false {
    Fail2ban::Jail['apache-noscript'] {
      findtime => $findtime,
    }
  }

}
