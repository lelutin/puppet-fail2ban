# Setup a fail2ban jail.
#
define fail2ban::jail (
  $port,
  $filter,
  $logpath   = false,
  $ensure    = present,
  $enabled   = true,
  $protocol  = false,
  $maxretry  = false,
  $findtime  = false,
  $action    = false,
  $banaction = false,
  $bantime   = false,
  $ignoreip  = [],
  $order     = false,
  $backend   = false,
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
    if $logpath {
      fail('logpath must not be set when $backend is \'systemd\'')
    }
  }
  else {
    if $logpath == false {
      fail('logpath must be set unless $backend is \'systemd\'')
    }
  }
  validate_array($ignoreip)

  if $::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '8') < 1 {
    if $ensure != present {
      warning('The $ensure parameter cannot be used on Debian wheezy. To ensure that a fail2ban jail is absent, simply remove the resource.')
    }
    # This has an implicit ordering that ensures proper functioning: the main
    # fragment is defined in the 'fail2ban::config' class and each fragment
    # implicitly requires the main concat target. Consequently, those fragments
    # are sure to be dealt with after package installation.
    concat::fragment { "jail_${name}":
      target  => '/etc/fail2ban/jail.conf',
      content => template('fail2ban/jail.erb'),
    }

    if $order != false {
      Concat::Fragment["jail_${name}"] {
        order => $order,
      }
    }
  }
  else {
    if $order {
      warning('The parameter order can presently only be used with Debian wheezy. It is planned to be removed when wheezy is no longer supported')
    }
    file { "/etc/fail2ban/jail.d/${name}.conf":
      ensure  => $ensure,
      content => template('fail2ban/jail.erb'),
      owner   => 'root',
      group   => 0,
      mode    => '0644',
    }
  }

}
