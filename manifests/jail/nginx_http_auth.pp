# Configure a fail2ban jail for nginx auth failures
#
# This jail requires nginx to be installed on the system, otherwise fail2ban
# will not start. Managing nginx is out of the scope of this module, so users
# should make sure to install nginx before the fail2ban service gets restarted.
#
class fail2ban::jail::nginx_http_auth (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  case $::osfamily {
    'Debian': {
      if $::lsbmajdistrelease != '7' {
        $logpath = '/var/log/nginx*/*error.log'
      }
      else {
        fail ('Debian wheezy is not supported for the nginx_http_auth jail: it doesn\'t have the appropriate filter')
      }
    }
    'RedHat': {
      $logpath = '%(nginx_error_log)s'
    }
    default: {
      fail("Unsupported Operating System family: ${::osfamily}")
    }
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
