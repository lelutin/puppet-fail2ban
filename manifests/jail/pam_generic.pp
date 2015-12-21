class fail2ban::jail::pam_generic (
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
    'RedHat' => '%(syslog_authpriv)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default pam-generic filter
  fail2ban::jail { 'pam-generic':
    enabled   => true,
    # port actually must be irrelevant but lets leave it "all" for some
    # possible uses
    port      => 'all',
    # pam-generic filter can be customized to monitor specific subset of 'tty's
    banaction => 'iptables-allports',
    filter    => 'pam-generic',
    logpath   => $logpath,
    maxretry  => $real_maxretry,
    findtime  => $findtime,
    ignoreip  => $ignoreip,
  }

}
