class fail2ban::jail::vsftpd (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    # path could be:
    # logpath = /var/log/auth.log
    # if you want to rely on PAM failed login attempts
    # vsftpd's failregex should match both of those formats
    # TODO: customizeable path?
    'Debian' => '/var/log/vsftpd.log',
    'RedHat' => '%(vsftpd_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default vsftpd filter
  fail2ban::jail { 'vsftpd':
    enabled  => true,
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'vsftpd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
