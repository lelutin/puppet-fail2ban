class fail2ban::jail::named_refused_tcp (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  # Use default named-refused filter
  fail2ban::jail { 'named-refused-tcp':
    enabled  => true,
    port     => 'domain,953',
    protocol => 'tcp',
    filter   => 'named-refused',
    logpath  => '/var/log/named/security.log',
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['named-refused-tcp'] {
      maxretry => $maxretry,
    }
  }

}
