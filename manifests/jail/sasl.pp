class fail2ban::jail::sasl (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false,
  $logpath  = false
) {

  if $logpath == false {
    $logpath = $::osfamily ? {
      'Debian' => '/var/log/mail.log',
      'RedHat' => '%(syslog_mail)s',
      default  => fail("Unsupported Operating System family: ${::osfamily}"),
    }
  }

  # Use default sasl filter from debian
  fail2ban::jail { 'sasl':
    enabled  => true,
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'sasl',
    # You might consider monitoring /var/log/mail.warn instead if you are
    # running postfix since it would provide the same log lines at the
    # "warn" level but overall at the smaller filesize.
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['sasl'] {
      maxretry => $maxretry,
    }
  }

}
