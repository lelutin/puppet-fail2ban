class fail2ban::jail::ssh_ddos {

  # Use default sshd-ddos filter from debian
  fail2ban::jail { 'ssh-ddos':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd-ddos',
    logpath  => '/var/log/auth.log',
    maxretry => '6',
  }

}
