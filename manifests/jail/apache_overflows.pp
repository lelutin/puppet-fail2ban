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
    'Gentoo' => '/var/log/apache*/*error.log',
    'RedHat' => '/var/log/httpd/*error.log',
    default  => fail ("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default apache-overflows filter from debian
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
