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
# @see https://github.com/fail2ban/fail2ban/blob/0.11/man/jail.conf.5 jail.conf(5)
#
# @note `blocktype` is not offered as a global option since it's not a great
#   idea to set a globally used default value for this option. It's used
#   differently by all actions and different values are expected from each
#   action, so it's generally recommended to override this for each action
#   individually by creating a `.local` file in `actions.d`.
#
#
# @example basic usage
#   class { 'fail2ban: }
#
# @example ignore localhost and another non-routable IP
#   class { 'fail2ban':
#     ignoreip => ['127.0.0.1', '10.0.0.1'],
#   }
#
#
# @param rm_fail2ban_local
#   Force removal of file /etc/fail2ban/fail2ban.local if present.
# @param rm_jail_local
#   Force removal of file /etc/fail2ban/jail.local if present.
# @param purge_fail2ban_dot_d
#   Remove all unmanaged files in /etc/fail2ban/fail2ban.d/
# @param purge_jail_dot_d
#   Remove all unmanaged files in /etc/fail2ban/jail.d/
# @param persistent_bans
#   Write out banned IPs to a file on teardown and restore bans when starting
#   fail2ban back up. This option is deprecated and is bound to be removed in
#   puppet-fail2ban 4.0
# @param config_file_mode
#   File mode set on all fail2ban configuration files managed by this module.
#
# @param loglvl
#   Set fail2ban's loglevel.
# @param logtarget
#   Define where fail2ban's logs are sent.
# @param syslogsocket
#   Path to syslog's socket file, or "auto" for automatically discovering it.
# @param socket
#   Path to fail2ban's own socket file. This file is used by fail2ban-client to
#   communicate with the daemon.
# @param pidfile
#   Path to fail2ban's pid file. This usually needs to be in a place where the
#   init script or systemd unit file can find it.
# @param dbfile
#   Path to fail2ban's database file.
# @param dbpurgeage
#   Age of entries in fail2ban's database that get removed when performing a
#   database purge operation.
#
# @param enabled
#   Whether or not to enable jails by default. fail2ban's man page recommends
#   to keep this to false, but by default the module purges jail.d of unknown
#   files so it might be safe to set to true in order to avoid repeating this
#   setting on all jails. If you set purge_jail_dot_d to false, it might be
#   wiser to keep this to false in order to avoid enabling jails that get
#   dropped in jail.d.
# @param filter
#   Default name of filter to use for jails.
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
#   Default email address used as recipient by actions that send out emails.
# @param sender
#   Default email address set as sender by actions that send out emails.
# @param fail2ban_agent
#   User-agent sent on HTTP requests that are made by some actions.
# @param banaction
#   Default action name extrapolated when defining some of the default actions.
# @param banaction_allports
#   Default action name that can be extrapolated when defining some of the
#   default actions. This one is meant to ban all ports at once instead of
#   specific ones.
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
# @param logpath
#   Default path to log file being used by jails. This value is usually not set
#   and logpath is defined for each jail for more clarity.
# @param logencoding
#   Name of the encoding of log files. If set to "auto", fail2ban will use what
#   is set in the system's locale setting.
# @param failregex
#   Regular expressions to add to all filters' failregex. This is usually not
#   used.
# @param ignoreregex
#   Regular expressions to add to all filters' ignoreregex. This is usually not
#   used but could be useful to have something excluded from bans everywhere.
# @param manage_service
#   Manage the fail2ban service, true by default
#
class fail2ban (
  # Options that change how the module behaves
  Boolean            $rm_fail2ban_local    = true,
  Boolean            $rm_jail_local        = true,
  Boolean            $purge_fail2ban_dot_d = true,
  Boolean            $purge_jail_dot_d     = true,
  Boolean            $persistent_bans      = false,
  String             $config_file_mode     = '0644',
  # Options for fail2ban.conf
  String[1]          $fail2ban_conf_template
    = 'fail2ban/fail2ban.conf.erb',
  Fail2ban::Loglevel $loglvl           = 'INFO',
  String             $logtarget        = '/var/log/fail2ban.log',
  String             $syslogsocket     = 'auto',
  String             $socket           = '/var/run/fail2ban/fail2ban.sock',
  String             $pidfile          = '/var/run/fail2ban/fail2ban.pid',
  String             $dbfile           = '/var/lib/fail2ban/fail2ban.sqlite3',
  Integer            $dbpurgeage       = 86400,
  # Options for jail.conf
  String[1]         $jail_conf_template
    = $fail2ban::params::jail_conf_template,
  Boolean            $enabled            = false,
  String             $filter             = '%(__name__)s',
  Array[String, 0]   $ignoreip           = ['127.0.0.1'],
  Integer            $bantime            = 600,
  Integer            $findtime           = 600,
  Integer            $maxretry           = 3,
  String             $ignorecommand      = '',
  Fail2ban::Backend  $backend            = 'auto',
  String             $destemail          = 'root@localhost',
  String             $sender             = 'root@localhost',
  String             $fail2ban_agent     = 'Fail2Ban/%(fail2ban_version)s',
  String             $banaction          = 'iptables-multiport',
  String             $banaction_allports = 'iptables-allports',
  String             $chain              = 'INPUT',
  Fail2ban::Port     $port               = '0:65535',
  String             $mta                = 'sendmail',
  Fail2ban::Protocol $protocol           = 'tcp',
  String             $action             = '%(action_)s',
  Fail2ban::Usedns   $usedns             = 'warn',
  Optional[String]   $logpath            = undef,
  String             $logencoding        = 'auto',
  Optional[String]   $failregex          = undef,
  Optional[String]   $ignoreregex        = undef,
  Boolean            $manage_service     = true,
) inherits fail2ban::params {

  if $persistent_bans {
    deprecation(
      'fail2ban_persistent_bans',
      'This option is bound to be removed in puppet-fail2ban 4.0: fail2ban now restores bans across service restarts.'
    )
  }

  contain fail2ban::install
  contain fail2ban::config
  contain fail2ban::service

  Class['fail2ban::install']
  -> Class['fail2ban::config']
  ~> Class['fail2ban::service']

}
