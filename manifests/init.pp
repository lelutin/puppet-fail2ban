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
# @param config_file_mode
#   File mode set on all fail2ban configuration files managed by this module.
# @param manage_service
#   Manage the fail2ban service, true by default
#
# @param fail2ban_conf_template
#   Alternative template to use for the `fail2ban.conf` file.
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
# @param dbmaxmatches
#   Number of matches stored in database per ticket.
# @param stacksize
#   Specifies the stack size (in KiB) to be used for subsequently created threads,
#   and must be 0 or a positive integer value of at least 32. 0 means that
#   fail2ban will use platform or configured default.
#
# @param jail_conf_template
#   Alternative template to use for the `jail.conf` file.
#
# @param enabled
#   Whether or not to enable jails by default. fail2ban's man page recommends
#   to keep this to false, but by default the module purges jail.d of unknown
#   files so it might be safe to set to true in order to avoid repeating this
#   setting on all jails. If you set purge_jail_dot_d to false, it might be
#   wiser to keep this to false in order to avoid enabling jails that get
#   dropped in jail.d.
# @param mode
#   Change the default behavior for filters. Watch out however, each
#   individual filter can define its own value and so most values are not
#   guaranteed to be available with all filters. The mode will generally
#   determine which regular expressions the filter will include. To know
#   exactly which values are available in filters, you need to read their
#   configuration files.
# @param backend
#   Default method used to get information from logs.
# @param usedns
#   Default behaviour whether or not to resolve IPs when they are found in a
#   log by a filter.
# @param filter
#   Default name of filter to use for jails.
# @param logpath
#   Array of absolute paths specifying the default path(s) to log file(s) being
#   used by jails. This value is usually not set and logpath is defined for
#   each jail for more clarity.
# @param logencoding
#   Name of the encoding of log files. If set to "auto", fail2ban will use what
#   is set in the system's locale setting.
# @param logtimezone
#   Force a timezone by default for logs that don't specify them on timestamps.
# @param prefregex
#   Regular expression to parse common part in every message.
# @param failregex
#   Array of regular expressions to add to all filters' failregex. This is
#   usually not used at the global level, but it can still be set.
# @param ignoreregex
#   Array of regular expressions to add to all filters' ignoreregex. This is
#   usually not used at the global level, but could be useful to have something
#   excluded from bans everywhere.
# @param ignoreself
#   If set to false, fail2ban will not ignore IP addresses that are bound to
#   interfaces on the host.
# @param ignoreip
#   Default list of IPs or CIDR prefixes that should not get banned.
# @param ignorecommand
#   Default command used to determine if an IP should be exempted from being
#   banned.
# @param ignorecache
#   If set, caches the results from `ignoreip`, `ignoreself` and
#   `ignorecommand` for a set amount of time to avoid calling `ignorecommand`
#   repeatedly.
# @param maxretry
#   Default number of times an IP should be detectd by a filter during findtime
#   for it to get banned.
# @param maxmatches
#   Number of matches stored in ticket.
# @param findtime
#   Default interval during which to count occurences of an IP.
# @param action
#   List of default actions that get called when an IP triggers maxretry number
#   of times a filter within findtime.
# @param bantime
#   Default duration in number of seconds to ban an IP address for.
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
# @param protocol
#   Default protocol name used by actions.
# @param mta
#   Default program name used for sending out email by actions that do so.
# @param destemail
#   Default email address used as recipient by actions that send out emails.
# @param sender
#   Default email address set as sender by actions that send out emails.
# @param fail2ban_agent
#   User-agent sent on HTTP requests that are made by some actions.
#
class fail2ban (
  # Options that change how the module behaves
  Boolean           $rm_fail2ban_local = true,
  Boolean           $rm_jail_local = true,
  Boolean           $purge_fail2ban_dot_d = true,
  Boolean           $purge_jail_dot_d = true,
  Stdlib::Filemode  $config_file_mode = '0644',
  Boolean           $manage_service = true,
  # Options for fail2ban.conf
  String[1]                          $fail2ban_conf_template = 'fail2ban/fail2ban.conf.epp',
  Fail2ban::Loglevel                 $loglvl = 'INFO',
  Fail2ban::Logtarget                $logtarget = '/var/log/fail2ban.log',
  Fail2ban::Syslogsocket             $syslogsocket = 'auto',
  Stdlib::Absolutepath               $socket = '/var/run/fail2ban/fail2ban.sock',
  Stdlib::Absolutepath               $pidfile = '/var/run/fail2ban/fail2ban.pid',
  Fail2ban::Dbfile                   $dbfile = '/var/lib/fail2ban/fail2ban.sqlite3',
  Integer                            $dbpurgeage = 86400,
  Integer                            $dbmaxmatches = 10,
  Variant[Integer[0,0], Integer[32]] $stacksize = 0,
  # Options for jail.conf
  String[1]                         $jail_conf_template = 'fail2ban/debian/jail.conf.epp',
  Boolean                           $enabled = false,
  String                            $mode = 'normal',
  Fail2ban::Backend                 $backend = 'auto',
  Fail2ban::Usedns                  $usedns = 'warn',
  String                            $filter = '%(__name__)s[mode=%(mode)s]',
  Array[String]                     $logpath = [],
  String                            $logencoding = 'auto',
  Optional[String]                  $logtimezone = undef,
  Optional[String]                  $prefregex = undef,
  Optional[Variant[String, Array[String[1]]]] $failregex = undef,
  Optional[Variant[String, Array[String[1]]]] $ignoreregex = undef,
  Boolean                           $ignoreself = true,
  Array[String, 0]                  $ignoreip = ['127.0.0.1'],
  String                            $ignorecommand = '',
  Optional[String]                  $ignorecache = undef,
  Integer[1]                        $maxretry = 3,
  Variant[Integer[1], String]       $maxmatches = '%(maxretry)s',
  Integer[1]                        $findtime = 600,
  Variant[String, Array[String, 1]] $action = ['%(action_)s'],
  Integer[0]                        $bantime = 600,
  String                            $banaction = 'iptables-multiport',
  String                            $banaction_allports = 'iptables-allports',
  String                            $chain = 'INPUT',
  Fail2ban::Port                    $port = '0:65535',
  Fail2ban::Protocol                $protocol = 'tcp',
  #  options for email-based actions
  String                            $mta = 'sendmail',
  String                            $destemail = 'root@localhost',
  String                            $sender = 'root@localhost',
  #  option for http-based actions
  String                            $fail2ban_agent = 'Fail2Ban/%(fail2ban_version)s',
) {

  if ! $facts['os']['family'] in ['Debian', 'RedHat'] {
    fail("Unsupported Operating System family: ${facts['os']['family']}")
  }

  if $action =~ String {
    deprecation('fail2ban_action_param',
      'The $action parameter will only take an array of strings in 5.x')
  }
  if $failregex =~ String {
    deprecation('fail2ban_failregex_param',
      'The $failregex parameter will only take an array of strings in 5.x')
  }
  if $ignoreregex =~ String {
    deprecation('fail2ban_ignoreregex_param',
      'The $ignoreregex parameter will only take an array of strings in 5.x')
  }

  contain fail2ban::install
  contain fail2ban::config
  contain fail2ban::service

  Class['fail2ban::install']
  -> Class['fail2ban::config']
  ~> Class['fail2ban::service']

}
