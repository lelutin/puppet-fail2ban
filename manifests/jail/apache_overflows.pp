class fail2ban::jail::apache_overflows {

  # Use default apache-overflows filter from debian
  fail2ban::jail { 'apache-overflows':
    enabled  => 'true',
    port     => 'http,https',
    filter   => 'apache-overflows',
    logpath  => '/var/log/apache*/*error.log',
    maxretry => '2',
  }

}
