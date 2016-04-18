class fail2ban::jail::courierauth (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/mail.log',
    'RedHat' => '%(syslog_mail)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default courierauth filter from debian
  fail2ban::jail { 'courierauth':
    enabled  => true,
    port     => 'smtp,smtps,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'courierlogin',
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['courierauth'] {
      maxretry => $maxretry,
    }
  }

}
