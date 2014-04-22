class fail2ban::jail::vsftpd (
  $maxretry = 'usedefault'
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default vsftpd filter from debian
  fail2ban::jail { 'vsftpd':
    enabled  => 'true',
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'vsftpd',
    # path could be:
    # logpath = /var/log/auth.log
    # if you want to rely on PAM failed login attempts
    # vsftpd's failregex should match both of those formats
    # TODO: customizeable path?
    logpath  => '/var/log/vsftpd.log',
    maxretry => $real_maxretry,
  }

}
