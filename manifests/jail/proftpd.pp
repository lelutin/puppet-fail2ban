class fail2ban::jail::proftpd (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/proftpd/proftpd.log',
    'RedHat' => '%(proftpd_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default proftpd filter
  fail2ban::jail { 'proftpd':
    enabled  => true,
    port     => 'ftp,ftp-data,ftps,ftps-data',
    filter   => 'proftpd',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
