class fail2ban::jail::couriersmtp (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/mail.log',
    'RedHat' => '%(syslog_mail)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default couriersmtp filter from debian
  fail2ban::jail { 'couriersmtp':
    enabled  => true,
    port     => 'smtp,smtps',
    filter   => 'couriersmtp',
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['couriersmtp'] {
      maxretry => $maxretry,
    }
  }

}
