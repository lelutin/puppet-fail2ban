class fail2ban::jail::ssh_pf (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
  $port     = ''
  ) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '3',
    default      => $maxretry
  }

  $real_port = $port ? {
    ''      => 'ssh',
    default => 'ssh'
  }

  $logpath = $::osfamily ? {
    /^(DragonFly|FreeBSD)$/ => '/var/log/auth.log',
    default                 => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default sshd filter
  fail2ban::jail { 'ssh-pf':
    enabled  => true,
    action   => 'pf',
    port     => $real_port,
    filter   => 'sshd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
