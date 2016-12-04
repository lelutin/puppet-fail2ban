# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
# Copyright (C) 2014-2016 gabster@lelutin.ca
#

class fail2ban (
  $ignoreip         = '127.0.0.1',
  $bantime          = '600',
  $findtime         = '600',
  $maxretry         = '3',
  $backend          = 'auto',
  $destemail        = 'root@localhost',
  $banaction        = 'iptables-multiport',
  $mta              = 'sendmail',
  $protocol         = 'tcp',
  $action           = '%(action_)s',
  $purge_jail_dot_d = true,
  $usedns           = 'warn',
  $persistent_bans  = false,
) {

  validate_re(
    $backend, ['auto', 'pyinotify', 'gamin', 'polling'],
    'backend must be one of auto, pyinotify, gamin or polling.'
  )
  validate_re(
    $protocol, ['tcp', 'udp', 'icmp', 'all'],
    'protocol must be one of tcp, udp, icmp or all.'
  )
  validate_bool($purge_jail_dot_d)
  validate_re(
    $usedns, ['yes', 'no', 'warn'], 'usedns value must be yes, no or warn.'
  )
  validate_bool($persistent_bans)

  anchor { 'fail2ban::begin': } ->
  class { 'fail2ban::install': } ->
  class { 'fail2ban::config': } ~>
  class { 'fail2ban::service': } ->
  anchor { 'fail2ban::end': }

}
