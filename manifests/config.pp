# Configure fail2ban service
#
# Setup jail.local as a concatenated file. This file will get all jails added
# to it.
class fail2ban::config {

  $ignoreip  = $fail2ban::ignoreip
  $bantime   = $fail2ban::bantime
  $findtime  = $fail2ban::findtime
  $maxretry  = $fail2ban::maxretry
  $backend   = $fail2ban::backend
  $destemail = $fail2ban::destemail
  $banaction = $fail2ban::banaction
  $mta       = $fail2ban::mta
  $protocol  = $fail2ban::protocol
  $action    = $fail2ban::action

  $config_dir = $::osfamily ? {
    /^(Debian|RedHat)$/     => '/etc/fail2ban',
    /^(DragonFly|FreeBSD)$/ => '/usr/local/etc/fail2ban',
  }

  $pf_path = $::osfamily ? {
    'DragonFly' => '/usr/sbin',
    'FreeBSD'   => '/sbin',
  }

  $jail_template_name = $::osfamily ? {
    'Debian'    => "${module_name}/debian_jail.conf.erb",
    'RedHat'    => "${module_name}/rhel_jail.conf.erb",
    'DragonFly' => "${module_name}/freebsd_jail.conf.erb",
    'FreeBSD'   => "${module_name}/freebsd_jail.conf.erb",
    default     => fail("Unsupported Operating System family: ${::osfamily}"),
  }

  if $fail2ban::purge_jail_dot_d {
    if $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 7 {
      debug('Not purging jail.d on wheezy since the package doesn\'t include capability to use it.')
    }
    else {
      file { "${config_dir}/jail.d":
        ensure  => directory,
        recurse => true,
        purge   => true,
      }
    }
  }

  file { "${config_dir}/jail.conf":
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template($jail_template_name),
  }

  concat { "${config_dir}/jail.local":
    owner => 0,
    group => 0,
    mode  => '0644',
  }
  # Define one fragment with a header for the file, otherwise the concat exec
  # errors out.
  concat::fragment { 'jail_header':
    target => "${config_dir}/jail.local",
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
      owner => 0,
      group => 0,
      mode  => '0644';
    }
  }

  if $::operatingsystem == 'freebsd' or $::operatingsystem == 'dragonfly' {
    file { "${config_dir}/action.d/pf.conf":
      ensure  => present,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => template("${module_name}/pf.conf.erb")
    }
  }

}
