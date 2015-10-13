class fail2ban::jail::courierauth (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  # Use default courierauth filter from debian
  fail2ban::jail { 'courierauth':
    enabled  => true,
    port     => 'smtp,ssmtp,imap2,imap3,imaps,pop3,pop3s',
    filter   => 'courierlogin',
    logpath  => '/var/log/mail.log',
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['courierauth'] {
      maxretry => $maxretry,
    }
  }

}
