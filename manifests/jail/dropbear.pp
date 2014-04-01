class fail2ban::jail::dropbear {

  # Use default sshd filter from debian
  fail2ban::jail { 'dropbear':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    logpath  => '/var/log/dropbear',
    maxretry => '6',
  }

}
