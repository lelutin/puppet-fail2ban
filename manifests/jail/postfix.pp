class fail2ban::jail::postfix {

  # Use default postfix filter from debian
  fail2ban::jail { 'postfix':
    enabled  => 'true',
    port     => 'smtp,ssmtp',
    filter   => 'postfix',
    logpath  => '/var/log/mail.log',
  }

}
