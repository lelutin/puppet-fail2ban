class fail2ban::jail::ssh (
  $maxretry = 'usedefault'
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default sshd filter from debian
  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    logpath  => '/var/log/auth.log',
    maxretry => $real_maxretry,
  }

}
