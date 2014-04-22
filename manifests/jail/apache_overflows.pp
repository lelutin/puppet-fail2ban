class fail2ban::jail::apache_overflows (
  $maxretry = 'usedefault'
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '2',
    default      => $maxretry
  }

  # Use default apache-overflows filter from debian
  fail2ban::jail { 'apache-overflows':
    enabled  => 'true',
    port     => 'http,https',
    filter   => 'apache-overflows',
    logpath  => '/var/log/apache*/*error.log',
    maxretry => $real_maxretry,
  }

}
