class fail2ban::jail::wuftpd {

  # Use default wuftpd filter from debian
  fail2ban::jail { 'wuftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'wuftpd',
    logpath  => '/var/log/auth.log',
    maxretry => '6',
  }

}
