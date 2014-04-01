class fail2ban::jail::sasl {

  # Use default sasl filter from debian
  fail2ban::jail { 'sasl':
    enabled  => 'true',
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'sasl',
    # You might consider monitoring /var/log/mail.warn instead if you are
    # running postfix since it would provide the same log lines at the
    # "warn" level but overall at the smaller filesize.
    #TODO: customizable path?
    logpath  => '/var/log/mail.log',
  }

}
