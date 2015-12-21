class fail2ban::jail::sendmailauth (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/mail.log',
    'RedHat' => '%(syslog_mail)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default sendmailauth filter from rhel
  fail2ban::jail { 'sendmailauth':
    enabled  => true,
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'sendmail-auth',
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['sendmailauth'] {
      maxretry => $maxretry,
    }
  }

}
