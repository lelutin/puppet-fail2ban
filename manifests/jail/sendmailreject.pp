class fail2ban::jail::sendmailreject (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  # Use default sendmailauth filter from rhel
  fail2ban::jail { 'sendmailreject':
    enabled  => true,
    port     => 'smtp,465,submission',
    filter   => 'sendmail-reject',
    logpath  => '%(syslog_mail)s',
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['sendmailreject'] {
      maxretry => $maxretry,
    }
  }

}
