class fail2ban::jail::proftpd (
  $maxretry = 'usedefault',
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default proftpd filter from debian
  fail2ban::jail { 'proftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'proftpd',
    logpath  => '/var/log/proftpd/proftpd.log',
    maxretry => $real_maxretry,
  }

}
