# Setup a fail2ban jail.
#
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
      warning('The parameter order can presently only be used with Debian wheezy. Il is planned to be removed when wheezy is no longer supported')
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
