class fail2ban::jail::pure_ftpd {

  # Use default pure-ftpd filter from debian
  fail2ban::jail { 'pure-ftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'pure-ftpd',
    logpath  => '/var/log/auth.log',
    maxretry => '6',
  }

}
