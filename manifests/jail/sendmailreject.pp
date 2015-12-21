class fail2ban::jail::sendmailreject (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/mail.log',
    'Gentoo' => '/var/log/mail.log',
    'RedHat' => '%(syslog_mail)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default sendmailauth filter from rhel
  fail2ban::jail { 'sendmailreject':
    enabled  => true,
    port     => 'smtp,465,submission',
    filter   => 'sendmail-reject',
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['sendmailreject'] {
      maxretry => $maxretry,
    }
  }

}
