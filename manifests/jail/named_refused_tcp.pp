class fail2ban::jail::named_refused_tcp (
  $maxretry = 'usedefault'
) {

  # Use default named-refused filter from debian
  fail2ban::jail { 'named-refused-tcp':
    enabled  => 'true',
    port     => 'domain,953',
    protocol => 'tcp',
    filter   => 'named-refused',
    logpath  => '/var/log/named/security.log',
  }

  if $maxretry != 'usedefault' {
    Fail2ban::Jail['named-refused-tcp'] {
      maxretry => $maxretry,
    }
  }
}
