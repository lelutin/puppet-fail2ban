class fail2ban::jail::wuftpd (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default wuftpd filter from debian
  fail2ban::jail { 'wuftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'wuftpd',
    logpath  => '/var/log/auth.log',
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
