class fail2ban::jail::dropbear (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/dropbear',
    'RedHat' => '%(dropbear_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default sshd filter
  fail2ban::jail { 'dropbear':
    enabled  => true,
    port     => 'ssh',
    filter   => 'sshd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
