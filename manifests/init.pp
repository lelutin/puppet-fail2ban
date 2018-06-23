# fail2ban/manifests/init.pp
#
# - Copyright (C) 2007 admin@immerda.ch
# - Copyright (C) 2014-2018 gabster@lelutin.ca
#
# @summary
#   Manage fail2ban and its configuration to jam bruteforce attempts on
#   services running on a computer.
#
# @api public
#
# @param rm_jail_local
#   Force removal of file /etc/fail2ban/jail.local if present.
# @param purge_jail_dot_d
#   Remove all unmanaged files in /etc/fail2ban/jail.d/
# @param persistent_bans
#   Write out banned IPs to a file on teardown and restore bans when starting
#   fail2ban back up. This option is deprecated and is bound to be removed in
#   puppet-fail2ban 4.0
#
# @param ignoreip
#   Default list of IPs or CIDR prefixes that should not get banned.
# @param bantime
#   Default duration in number of seconds to ban an IP address for.
# @param findtime
#   Default interval during which to count occurences of an IP.
# @param maxretry
#   Default number of times an IP should be detectd by a filter during findtime
#   for it to get banned.
# @param ignorecommand
#   Default command used to determine if an IP should be exempted from being
#   banned.
# @param backend
#   Default method used to get information from logs.
# @param destemail
#   Default email address used by actions that send out emails.
# @param banaction
#   Default action name extrapolated when defining some of the default actions.
# @param chain
#   Default name of the iptables chain used by iptables-based actions.
# @param port
#   Default comma separated list of ports, port names or port ranges used by
#   actions when banning an IP.
# @param mta
#   Default program name used for sending out email by actions that do so.
# @param protocol
#   Default protocol name used by actions.
# @param action
#   Default action that gets called when an IP triggers maxretry number of
#   times a filter within findtime.
# @param usedns
#   Default behaviour whether or not to resolve IPs when they are found in a
#   log by a filter.
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
