class fail2ban::jail::apache_noscript {

  # Use default apache-noscript filter from debian
  fail2ban::jail { 'apache-noscript':
    enabled  => 'true',
    port     => 'http,https',
    filter   => 'apache-noscript',
    logpath  => '/var/log/apache*/*error.log',
    maxretry => '6',
  }

}
