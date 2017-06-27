# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
# Copyright (C) 2014-2016 gabster@lelutin.ca
#

class fail2ban (
  $ignoreip         = ['127.0.0.1'],
  $bantime          = '600',
  $findtime         = '600',
  $maxretry         = '3',
  $backend          = 'auto',
  $destemail        = 'root@localhost',
  $banaction        = 'iptables-multiport',
  $mta              = 'sendmail',
  $protocol         = 'tcp',
  $action           = '%(action_)s',
  $rm_jail_local    = true,
  $purge_jail_dot_d = true,
  $usedns           = 'warn',
  $persistent_bans  = false,
) {

  validate_array($ignoreip)
  $valid_backends = [
      'auto',
      'pyinotify',
      'gamin',
      'polling',
      'systemd'
  ]
  $valid_backend_message = join($valid_backends, ', ')

  validate_re(
    $backend, $valid_backends,
    "backend must be one of: ${valid_backend_message}."
  )
  validate_re(
    $protocol, ['tcp', 'udp', 'icmp', 'all'],
    'protocol must be one of tcp, udp, icmp or all.'
  )
  validate_bool($rm_jail_local)
  validate_bool($purge_jail_dot_d)
  validate_re(
    $usedns, ['yes', 'no', 'warn'], 'usedns value must be yes, no or warn.'
  )
  validate_bool($persistent_bans)

  anchor { 'fail2ban::begin': }
  -> class { 'fail2ban::install': }
  -> class { 'fail2ban::config': }
  ~> class { 'fail2ban::service': }
  -> anchor { 'fail2ban::end': }

}
