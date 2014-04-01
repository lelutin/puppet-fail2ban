class fail2ban::jail::ssh {

  # Use default sshd filter from debian
  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    logpath  => '/var/log/auth.log',
    maxretry => '6',
  }

}
