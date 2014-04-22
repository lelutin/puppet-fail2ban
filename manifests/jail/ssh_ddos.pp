class fail2ban::jail::ssh_ddos (
  $maxretry = 'usedefault'
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default sshd-ddos filter from debian
  fail2ban::jail { 'ssh-ddos':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd-ddos',
    logpath  => '/var/log/auth.log',
    maxretry => $real_maxretry,
  }

}
