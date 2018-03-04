# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
# Copyright (C) 2014-2016 gabster@lelutin.ca
#

class fail2ban (
  # Options for jail.conf
  Array[String, 0] $ignoreip = ['127.0.0.1'],
  #TODO can the three following params be forced to integers?
  $bantime          = '600',
  $findtime         = '600',
  $maxretry         = '3',
  String $ignorecommand = '',
  Enum['auto','pyinotify','gamin','polling','systemd'] $backend = 'auto',
  String $destemail = 'root@localhost',
  String $banaction = 'iptables-multiport',
  String $chain = 'INPUT',
  String $mta = 'sendmail',
  Enum['tcp','udp','icmp','all'] $protocol = 'tcp',
  String $action = '%(action_)s',
  Enum['yes','no','warn'] $usedns = 'warn',
  # Options that change how the module behaves
  Boolean $rm_jail_local = true,
  Boolean $purge_jail_dot_d = true,
  Boolean $persistent_bans = false,
) {

  anchor { 'fail2ban::begin': }
  -> class { 'fail2ban::install': }
  -> class { 'fail2ban::config': }
  ~> class { 'fail2ban::service': }
  -> anchor { 'fail2ban::end': }

}
