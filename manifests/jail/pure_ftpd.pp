class fail2ban::jail::pure_ftpd (
  $maxretry = 'usedefault',
  $findtime = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default pure-ftpd filter from debian
  fail2ban::jail { 'pure-ftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'pure-ftpd',
    logpath  => '/var/log/auth.log',
    maxretry => $real_maxretry,
  }

  if $findtime != false {
    Fail2ban::Jail['pure-ftpd'] {
      findtime => $findtime,
    }
  }

}
