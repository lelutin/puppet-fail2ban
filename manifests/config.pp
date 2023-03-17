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

  $fail2ban_conf_options = {
    loglvl           => $fail2ban::loglvl,
    logtarget        => $fail2ban::logtarget,
    syslogsocket     => $fail2ban::syslogsocket,
    socket           => $fail2ban::socket,
    pidfile          => $fail2ban::pidfile,
    dbfile           => $fail2ban::dbfile,
    dbpurgeage       => $fail2ban::dbpurgeage,
    dbmaxmatches     => $fail2ban::dbmaxmatches,
    stacksize        => $fail2ban::stacksize,
  }

  file { '/etc/fail2ban/fail2ban.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => $fail2ban::config_file_mode,
    content => epp($fail2ban::fail2ban_conf_template, $fail2ban_conf_options),
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

  if $fail2ban::purge_jail_dot_d {
    file { '/etc/fail2ban/jail.d':
      ensure  => directory,
      recurse => true,
      purge   => true,
    }
  }

  $jail_conf_options = {
    ignoreself         => $fail2ban::ignoreself,
    ignoreip           => $fail2ban::ignoreip,
    ignorecommand      => $fail2ban::ignorecommand,
    ignorecache        => $fail2ban::ignorecache,
    bantime            => $fail2ban::bantime,
    findtime           => $fail2ban::findtime,
    maxretry           => $fail2ban::maxretry,
    maxmatches         => $fail2ban::maxmatches,
    backend            => $fail2ban::backend,
    usedns             => $fail2ban::usedns,
    logencoding        => $fail2ban::logencoding,
    logtimezone        => $fail2ban::logtimezone,
    logpath            => $fail2ban::logpath,
    enabled            => $fail2ban::enabled,
    mode               => $fail2ban::mode,
    filter             => $fail2ban::filter,
    prefregex          => $fail2ban::prefregex,
    failregex          => $fail2ban::failregex,
    ignoreregex        => $fail2ban::ignoreregex,
    destemail          => $fail2ban::destemail,
    sender             => $fail2ban::sender,
    mta                => $fail2ban::mta,
    protocol           => $fail2ban::protocol,
    chain              => $fail2ban::chain,
    port               => $fail2ban::port,
    fail2ban_agent     => $fail2ban::fail2ban_agent,
    banaction          => $fail2ban::banaction,
    banaction_allports => $fail2ban::banaction_allports,
    action             => $fail2ban::action,
  }

  file { '/etc/fail2ban/jail.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => $fail2ban::config_file_mode,
    content => epp($fail2ban::jail_conf_template, $jail_conf_options),
  }

  if $fail2ban::rm_jail_local {
    file { '/etc/fail2ban/jail.local':
      ensure => absent,
    }
  }

}
