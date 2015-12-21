class fail2ban::jail::apache (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/apache*/*error.log',
    'RedHat' => '%(apache_error_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default apache-auth filter
  fail2ban::jail { 'apache':
    enabled  => true,
    port     => 'http,https',
    filter   => 'apache-auth',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
