class fail2ban::jail::named_refused_tcp {

  # Use default named-refused filter from debian
  fail2ban::jail { 'named-refused-tcp':
    enabled  => 'true',
    port     => 'domain,953',
    protocol => 'tcp',
    filter   => 'named-refused',
    logpath  => '/var/log/named/security.log',
  }

}
