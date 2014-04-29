class fail2ban::jail::dovecot (
  $maxretry = 'usedefault',
  $findtime = false
) {

  # Use default dovecot filter from debian
  fail2ban::jail { 'dovecot':
    enabled  => 'true',
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'dovecot',
    logpath  => '/var/log/mail.log',
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['dovecot'] {
      maxretry => $maxretry,
    }
  }

  if $findtime != false {
    Fail2ban::Jail['dovecot'] {
      findtime => $findtime,
    }
  }

}
