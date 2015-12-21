class fail2ban::jail::wuftpd (
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
    'RedHat' => '%(wuftpd_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default wuftpd filter
  fail2ban::jail { 'wuftpd':
    enabled  => true,
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'wuftpd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
