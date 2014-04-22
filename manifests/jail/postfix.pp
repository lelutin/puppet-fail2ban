class fail2ban::jail::postfix (
  $maxretry = 'usedefault'
) {

  # Use default postfix filter from debian
  fail2ban::jail { 'postfix':
    enabled  => 'true',
    port     => 'smtp,ssmtp',
    filter   => 'postfix',
    logpath  => '/var/log/mail.log',
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['postfix'] {
      maxretry => $maxretry,
    }
  }

}
