class fail2ban::jail::proftpd {

  # Use default proftpd filter from debian
  fail2ban::jail { 'proftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'proftpd',
    logpath  => '/var/log/proftpd/proftpd.log',
    maxretry => '6',
  }

}
