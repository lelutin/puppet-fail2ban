# Configure fail2ban service
#
# Setup jail.local as a concatenated file. This file will get all jails added
# to it.
class fail2ban::config {

  $loglevel        = $fail2ban::loglevel
  $logtarget       = $fail2ban::logtarget
  $syslogsocket    = $fail2ban::syslogsocket
  $socket          = $fail2ban::socket
  $pidfile         = $fail2ban::pidfile
  $dbfile          = $fail2ban::dbfile
  $dbpurgeage      = $fail2ban::dbpurgeage
  $ignoreip        = $fail2ban::ignoreip
  $bantime         = $fail2ban::bantime
  $findtime        = $fail2ban::findtime
  $maxretry        = $fail2ban::maxretry
  $backend         = $fail2ban::backend
  $usedns          = $fail2ban::usedns
  $destemail       = $fail2ban::destemail
  $banaction       = $fail2ban::banaction
  $mta             = $fail2ban::mta
  $protocol        = $fail2ban::protocol
  $action          = $fail2ban::action
  $persistent_bans = $fail2ban::persistent_bans

  validate_integer($bantime)
  validate_integer($findtime)
  validate_integer($maxretry)
  validate_bool($persistent_bans)
  validate_re($usedns, [ 'yes', 'no', 'warn' ], 'usedns value must be yes, no or warn.')

  $jail_template_name = $::osfamily ? {
    'Debian' => "${module_name}/debian_jail.conf.erb",
    'RedHat' => "${module_name}/rhel_jail.conf.erb",
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  $before_include = $::osfamily ? {
    'Debian' => "iptables-blocktype.conf",
    'RedHat' => "iptables-common.conf",
    default  => fail("Unsupported Operating System family: ${::osfamily}"),
  }
  
  file { '/etc/fail2ban/fail2ban.local':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template('fail2ban/fail2ban.local.erb'),
  }

  if $fail2ban::purge_jail_dot_d {
    if $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 7 {
      debug('Not purging jail.d on wheezy since the package doesn\'t include capability to use it.')
    }
    else {
      file { '/etc/fail2ban/jail.d':
        ensure  => directory,
        recurse => true,
        purge   => true,
      }
    }
  }

  file { '/etc/fail2ban/jail.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template($jail_template_name),
  }

  concat { '/etc/fail2ban/jail.local':
    owner => 'root',
    # The next line is not portable to some BSDs, but since the concat module
    # doesn't let one use integer values for the $group parameter (doing so
    # produces an error with future parser or 4.x) we're using a string value
    # instead.
    # See https://tickets.puppetlabs.com/browse/MODULES-2999 for report on the
    # concat module. If this gets fixed and the concat module permits usage of
    # integer values, we'll switch back to using a value of 0 for the $group
    # parameter.
    group => 'root',
    mode  => '0644',
  }
  # Define one fragment with a header for the file, otherwise the concat exec
  # errors out.
  concat::fragment { 'jail_header':
    target => '/etc/fail2ban/jail.local',
    source => 'puppet:///modules/fail2ban/jail.header',
    order  => 01,
  }

  if $::operatingsystem == 'gentoo' {
    file { '/etc/conf.d/fail2ban':
      ensure => present,
      source => [
        "puppet:///modules/site_fail2ban/conf.d/${::fqdn}/fail2ban",
        'puppet:///modules/site_fail2ban/conf.d/fail2ban',
        'puppet:///modules/fail2ban/conf.d/fail2ban'
      ],
      owner => 'root',
      group => 0,
      mode  => '0644';
    }
  }

  if $persistent_bans {
    file { '/etc/fail2ban/persistent.bans':
      ensure  => 'present',
      replace => 'no',
      mode    => '0644',
    }
    file { '/etc/fail2ban/action.d/iptables-multiport.conf':
      ensure  => present,
      owner   => 'root',
      group   => 0,
      mode    => '0644',
      content => template('fail2ban/iptables-multiport.erb'),
    }
  }
}
