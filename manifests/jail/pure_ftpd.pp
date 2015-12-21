class fail2ban::jail::pure_ftpd (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/auth.log',
    'RedHat' => '%(pureftpd_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default pure-ftpd filter
  fail2ban::jail { 'pure-ftpd':
    enabled  => true,
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'pure-ftpd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
