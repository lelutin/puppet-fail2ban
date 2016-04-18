class fail2ban::jail::postfix (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/mail.log',
    'RedHat' => '%(postfix_log)s',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default postfix filter
  fail2ban::jail { 'postfix':
    enabled  => true,
    port     => 'smtp,smtps',
    filter   => 'postfix',
    logpath  => $logpath,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['postfix'] {
      maxretry => $maxretry,
    }
  }

}
