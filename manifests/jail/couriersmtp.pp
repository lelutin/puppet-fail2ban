class fail2ban::jail::couriersmtp {

  # Use default couriersmtp filter from debian
  fail2ban::jail { 'couriersmtp':
    enabled  => 'true',
    port     => 'smtp,ssmtp',
    filter   => 'couriersmtp',
    logpath  => '/var/log/mail.log',
  }

}
