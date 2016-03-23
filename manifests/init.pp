# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
# Copyright (C) 2014-2016 gabster@lelutin.ca
#

class fail2ban (
  $ignoreip         = '127.0.0.1',
  $bantime          = '600',
  $findtime         = '600',
  $maxretry         = '3',
  $backend          = 'polling',
  $destemail        = 'root@localhost',
  $banaction        = 'iptables-multiport',
  $mta              = 'sendmail',
  $protocol         = 'tcp',
  $action           = '%(action_)s',
  $purge_jail_dot_d = true
) {

  anchor { 'fail2ban::begin': } ->
  class { 'fail2ban::install': } ->
  class { 'fail2ban::config': } ~>
  class { 'fail2ban::service': } ->
  anchor { 'fail2ban::end': }

}
