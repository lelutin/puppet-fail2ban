class fail2ban::jail::apache_overflows (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '2',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/apache*/*error.log',
    'RedHat' => '%(apache_error_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default apache-overflows filter
  fail2ban::jail { 'apache-overflows':
    enabled  => true,
    port     => 'http,https',
    filter   => 'apache-overflows',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
