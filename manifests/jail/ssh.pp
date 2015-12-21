class fail2ban::jail::ssh (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/auth.log',
    'RedHat' => '%(sshd_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default sshd filter
  fail2ban::jail { 'ssh':
    enabled  => true,
    port     => 'ssh',
    filter   => 'sshd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
