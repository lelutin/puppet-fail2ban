class fail2ban::jail::ssh_ddos (
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

  # Use default sshd-ddos filter
  fail2ban::jail { 'ssh-ddos':
    enabled  => true,
    port     => 'ssh',
    filter   => 'sshd-ddos',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
