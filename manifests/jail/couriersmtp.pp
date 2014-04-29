class fail2ban::jail::couriersmtp (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  # Use default couriersmtp filter from debian
  fail2ban::jail { 'couriersmtp':
    enabled  => 'true',
    port     => 'smtp,ssmtp',
    filter   => 'couriersmtp',
    logpath  => '/var/log/mail.log',
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['couriersmtp'] {
      maxretry => $maxretry,
    }
  }

}
