# Configure fail2ban service
#
# Setup jail.local as a concatenated file. This file will get all jails added
# to it.
class fail2ban::config {

  $ignoreip = $fail2ban::ignoreip
  $bantime = $fail2ban::bantime
  $maxretry = $fail2ban::maxretry
  $backend = $fail2ban::backend
  $destemail = $fail2ban::destemail
  $banaction = $fail2ban::banaction
  $mta = $fail2ban::mta
  $protocol = $fail2ban::protocol
  $action = $fail2ban::action
  file { '/etc/fail2ban/jail.conf':
    ensure  => present,
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('fail2ban/jail.conf.erb'),
  }

  concat { '/etc/fail2ban/jail.local':
    owner => 'root',
    group => '0',
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
      group => '0',
      mode  => '0644';
    }
  }

}
