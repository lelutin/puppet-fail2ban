class fail2ban::jail::nginx_http_auth (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  $logpath = $::osfamily ? {
    'Debian' => '/var/log/nginx*/*error.log',
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  # Use default nginx-http-auth filter
  fail2ban::jail { 'nginx-http-auth':
    enabled  => true,
    port     => 'http,https',
    filter   => 'nginx-http-auth',
    logpath  => $logpath,
    maxretry => $real_maxretry,
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
