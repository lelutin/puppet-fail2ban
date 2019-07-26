# fail2ban/manifests/config.pp
#
# This class should not be included directly. Users must use the fail2ban
# class.
#
# @summary Configure fail2ban service
#
# @api private
#
class fail2ban::config {

  $loglvl = $fail2ban::loglvl
  $logtarget = $fail2ban::logtarget
  $syslogsocket = $fail2ban::syslogsocket
  $socket = $fail2ban::socket
  $pidfile = $fail2ban::pidfile
  $dbfile = $fail2ban::dbfile
  $dbpurgeage = $fail2ban::dbpurgeage

  file { '/etc/fail2ban/fail2ban.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template($fail2ban::fail2ban_conf_template),
  }

  if $fail2ban::rm_fail2ban_local {
    file { '/etc/fail2ban/fail2ban.local':
      ensure => absent,
    }
  }
  if $fail2ban::purge_fail2ban_dot_d {
    file { '/etc/fail2ban/fail2ban.d':
      ensure  => directory,
      recurse => true,
      purge   => true,
    }
  }


  $persistent_bans = $fail2ban::persistent_bans

  $enabled = $fail2ban::enabled
  $filter = $fail2ban::filter
  $ignoreip = $fail2ban::ignoreip
  $bantime = $fail2ban::bantime
  $findtime = $fail2ban::findtime
  $maxretry = $fail2ban::maxretry
  $ignorecommand = $fail2ban::ignorecommand
  $backend = $fail2ban::backend
  $destemail = $fail2ban::destemail
  $sender = $fail2ban::sender
  $fail2ban_agent = $fail2ban::fail2ban_agent
  $banaction = $fail2ban::banaction
  $banaction_allports = $fail2ban::banaction_allports
  $chain = $fail2ban::chain
  $port = $fail2ban::port
  $mta = $fail2ban::mta
  $protocol = $fail2ban::protocol
  $action = $fail2ban::action
  $usedns = $fail2ban::usedns
  $logpath = $fail2ban::logpath
  $logencoding = $fail2ban::logencoding
  $failregex = $fail2ban::failregex
  $ignoreregex = $fail2ban::ignoreregex

  $before_include = 'iptables-common.conf'

  if $fail2ban::purge_jail_dot_d {
    file { '/etc/fail2ban/jail.d':
      ensure  => directory,
      recurse => true,
      purge   => true,
    }
  }
  if $persistent_bans {
    file { '/etc/fail2ban/persistent.bans':
      ensure  => 'present',
      replace => 'no',
      mode    => '0644',
    }
  }
  file { '/etc/fail2ban/action.d/iptables-multiport.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template('fail2ban/iptables-multiport.erb'),
  }

  file { '/etc/fail2ban/jail.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template($fail2ban::jail_conf_template),
  }

  if $fail2ban::rm_jail_local {
    file { '/etc/fail2ban/jail.local':
      ensure => absent,
    }
  }

}
