# Setup a fail2ban jail.
define fail2ban::jail (
  $port,
  $filter,
  $logpath,
  $ensure    = present,
  $enabled   = true,
  $protocol  = false,
  $maxretry  = false,
  $findtime  = false,
  $action    = false,
  $banaction = false,
  $bantime   = false,
  $ignoreip  = false,
  $order     = false,
  $backend   = false,
) {
  include fail2ban::config

  if $ensure != present {
    warning('The $ensure parameter is now deprecated! to ensure that a fail2ban jail is absent, simply remove the resource.')
  }

  # This has an implicit ordering that ensures proper functioning: the main
  # fragment is defined in the 'fail2ban::config' class and each fragment
  # implicitly requires the main concat target. Consequently, those fragments
  # are sure to be dealt with after package installation.
  concat::fragment { "jail_${name}":
    target  => '/etc/fail2ban/jail.local',
    content => template('fail2ban/jail.erb'),
  }

  if $order != false {
    Concat::Fragment["jail_${name}"] {
      order => $order,
    }
  }

}
