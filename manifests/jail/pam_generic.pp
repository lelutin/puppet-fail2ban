class fail2ban::jail::pam_generic (
  $maxretry = 'usedefault',
  $findtime = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  # Use default pam-generic filter from debian
  fail2ban::jail { 'pam-generic':
    enabled   => 'true',
    # port actually must be irrelevant but lets leave it "all" for some
    # possible uses
    port      => 'all',
    # pam-generic filter can be customized to monitor specific subset of 'tty's
    banaction => 'iptables-allports',
    filter    => 'pam-generic',
    logpath   => '/var/log/auth.log',
    maxretry  => $real_maxretry,
  }

  if $findtime != false {
    Fail2ban::Jail['pam-generic'] {
      findtime => $findtime,
    }
  }

}
