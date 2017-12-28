# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
# Copyright (C) 2014-2016 gabster@lelutin.ca
#

class fail2ban (
  # Options for jail.conf
  $ignoreip         = ['127.0.0.1'],
  $bantime          = '600',
  $findtime         = '600',
  $maxretry         = '3',
  $backend          = 'auto',
  $destemail        = 'root@localhost',
  $banaction        = 'iptables-multiport',
  $chain            = 'INPUT',
  $mta              = 'sendmail',
  $protocol         = 'tcp',
  $action           = '%(action_)s',
  $usedns           = 'warn',
  # Options that change how the module behaves
  $rm_jail_local    = true,
  $purge_jail_dot_d = true,
  $persistent_bans  = false,
) {

  validate_legacy('Stdlib::Compat::Array', 'validate_array', $ignoreip)
  $valid_backends = [
      'auto',
      'pyinotify',
      'gamin',
      'polling',
      'systemd'
  ]
  $valid_backend_message = join($valid_backends, ', ')

  validate_legacy('Pattern', 'validate_re',
    $backend, $valid_backends,
    "backend must be one of: ${valid_backend_message}."
  )
  validate_legacy('Pattern', 'validate_re',
    $protocol, ['tcp', 'udp', 'icmp', 'all'],
    'protocol must be one of tcp, udp, icmp or all.'
  )
  validate_legacy('Stdlib::Compat::Bool', 'validate_bool', $rm_jail_local)
  validate_legacy('Stdlib::Compat::Bool', 'validate_bool', $purge_jail_dot_d)
  validate_legacy('Pattern', 'validate_re',
    $usedns, ['yes', 'no', 'warn'], 'usedns value must be yes, no or warn.'
  )
  validate_legacy('Stdlib::Compat::Bool', 'validate_bool', $persistent_bans)

  anchor { 'fail2ban::begin': }
  -> class { 'fail2ban::install': }
  -> class { 'fail2ban::config': }
  ~> class { 'fail2ban::service': }
  -> anchor { 'fail2ban::end': }

}
