# Setup a fail2ban jail.
#
define fail2ban::jail (
  $port,
  $filter,
  $logpath       = false,
  $ensure        = present,
  $enabled       = true,
  $protocol      = false,
  $maxretry      = false,
  $findtime      = false,
  $ignorecommand = false,
  $action        = false,
  $banaction     = false,
  $bantime       = false,
  $ignoreip      = [],
  $backend       = false,
) {
  include fail2ban::config

  validate_re(
    $ensure, ['present', 'absent'], 'ensure must be either present or absent.'
  )
  validate_bool($enabled)
  if $maxretry { validate_integer($maxretry, '', 0) }
  if $findtime { validate_integer($findtime, '', 0) }
  if $bantime { validate_integer($bantime, '', 0) }
  if $backend == 'systemd' {
    if $logpath {
      fail('logpath must not be set when $backend is \'systemd\'')
    }
  }
  else {
    if $logpath == false {
      fail('logpath must be set unless $backend is \'systemd\'')
    }
  }
  validate_array($ignoreip)

  if $port == 'all' {
    $portrange = '1:65535'
  }
  else
  {
    $portrange = $port
  }

  file { "/etc/fail2ban/jail.d/${name}.conf":
    ensure  => $ensure,
    content => template('fail2ban/jail.erb'),
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    notify  => Class['fail2ban::service']
  }

}
