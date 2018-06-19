# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
# Copyright (C) 2014-2016 gabster@lelutin.ca
#

class fail2ban (
  # Options that change how the module behaves
  Boolean            $rm_jail_local    = true,
  Boolean            $purge_jail_dot_d = true,
  Boolean            $persistent_bans  = false,
  # Options for jail.conf
  Array[String, 0]   $ignoreip         = ['127.0.0.1'],
  Integer            $bantime          = 600,
  Integer            $findtime         = 600,
  Integer            $maxretry         = 3,
  String             $ignorecommand    = '',
  Fail2ban::Backend  $backend          = 'auto',
  String             $destemail        = 'root@localhost',
  String             $banaction        = 'iptables-multiport',
  String             $chain            = 'INPUT',
  Fail2ban::Port     $port             = '0:65535',
  String             $mta              = 'sendmail',
  Fail2ban::Protocol $protocol         = 'tcp',
  String             $action           = '%(action_)s',
  Fail2ban::Usedns   $usedns           = 'warn',
) {

  contain fail2ban::install
  contain fail2ban::config
  contain fail2ban::service

  Class['fail2ban::install']
  -> Class['fail2ban::config']
  ~> Class['fail2ban::service']

}
