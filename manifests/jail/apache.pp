class fail2ban::jail::apache {

  # Use default apache-auth filter from debian
  fail2ban::jail { 'apache':
    enabled  => 'true',
    port     => 'http,https',
    filter   => 'apache-auth',
    logpath  => '/var/log/apache*/*error.log',
    maxretry => '6',
  }

}
