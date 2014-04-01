class fail2ban::jail::dovecot {

  # Use default dovecot filter from debian
  fail2ban::jail { 'dovecot':
    enabled  => 'true',
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'dovecot',
    logpath  => '/var/log/mail.log',
  }

}
