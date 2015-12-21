class fail2ban::jail::dovecot (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/mail.log',
    'RedHat' => '%(dovecot_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default dovecot filter
  fail2ban::jail { 'dovecot':
    enabled  => true,
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'dovecot',
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['dovecot'] {
      maxretry => $maxretry,
    }
  }

}
