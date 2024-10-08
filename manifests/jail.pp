# fail2ban/manifests/jail.pp
#
# - Copyright (C) 2014-2018 gabster@lelutin.ca
#
# Jails are the top level of fail2ban configuration; what you'll be using most
# often to setup protection of a service from bruteforce attempts or pesky
# attack traffic. They rely on a filter to find out IPs that are doing
# mischief, and then use an action to ban (and subsequently unban) IPs.
#
# Most parameters of this defined type are used for overriding what has been
# set in the global context in jail.conf/jail.local (see parameters to the
# fail2ban class). They are not mandatory if you can reuse the global values.
#
# @summary Setup a fail2ban jail to reduce effectiveness of bruteforce.
#
# @api public
#
# @see https://github.com/fail2ban/fail2ban/blob/0.11/man/jail.conf.5 jail.conf(5)
#
#
# @example creating simple jail for service
#   fail2ban::jail { 'honeypot':
#     findtime => 300,
#     maxretry => 1,
#     port     => 'all',
#     logpath  => ['/var/log/honeypot.log'],
#   }
#
# @example using a pre-defined jail
#   $ssh_params = lookup('fail2ban::jail::sshd')
#   fail2ban::jail { 'sshd':
#     * => $ssh_params,
#   }
#
# @example overriding parameters from a pre-defined jail
#   $ssh_extra_params  = {
#     'bantime'  => 300,
#     'findtime' => 200,
#     'maxretry' => 3,
#   }
#   $ssh_params = lookup('fail2ban::jail::sshd') + $ssh_extra_params
#   fail2ban::jail { 'sshd':
#     * => $ssh_params,
#   }
#
#
# @param ensure
#   Whether resources for the defined jail should be installed or removed.
# @param config_file_mode
#   Permission mode given to the jail file created by this defined type.
#
# @param enabled
#   Whether or not a jail is enabled. Setting this to false makes it possible
#   to keep configuration around for a certain jail but temporarily disable it.
# @param mode
#   Change the behavior of the filter used by this jail. The mode will
#   generally determine which regular expressions the filter will include. The
#   values that this can take are determined by each individual filter. To know
#   exactly which values are available in filters, you need to read their
#   configuration files.
# @param backend
#   Method used by fail2ban to obtain new log lines from the log file(s) in
#   logpath.
# @param usedns
#   Whether or not to resolve DNS hostname of IPs that have been found by a
#   failregex.
# @param filter
#   Name of the filter to use for this jail. The default value for the filter
#   is usually to use a filter with the same name as the jail name (although
#   this could be changed by the filter parameter on the fail2ban class).
# @param logpath
#   Array of absolute paths to the log files against which regular expressions
#   should be verified to catch activity that you want to block. This
#   parameter must be set to a non-empty array when not using the 'systemd'
#   backend, however it must be empty if the 'systemd' backend is used.
# @param logencoding
#   Name of the encoding of log files. If set to "auto", fail2ban will use what
#   is set in the system's locale setting.
# @param logtimezone
#   Force a timezone if the logs don't specify them on timestamps.
# @param datepattern
#   Change the format of dates recognized by the filter this jail uses.
# @param prefregex
#   Regular expression to parse common part in every message for this jail.
# @param failregex
#   Regular expressions to add to the failregex of the filter used by this
#   jail.
# @param ignoreregex
#   Regular expressions to add to the ignoreregex of the filter used by this
#   jail.
# @param ignoreself
#   If set to false, fail2ban will not ignore IP addresses, for this jail, that
#   are bound to interfaces on the host.
# @param ignoreip
#   List of IPs or CIDR prefixes to ignore when identifying matches of
#   failregex. The IPs that fit the descriptions in this parameter will never
#   get banned by the jail.
# @param ignorecommand
#   Command used to determine if an IP should found by a failregex be ignored.
#   This can be used to have a more complex and dynamic method of listing and
#   identifying IPs that should not get banned. It can be used also when
#   ignoreip is present.
# @param ignorecache
#   If set, caches the results from `ignoreip`, `ignoreself` and
#   `ignorecommand` for a set amount of time to avoid calling `ignorecommand`
#   repeatedly.
# @param maxretry
#   Number of failregex matches during findtime after which an IP gets banned.
# @param maxlines
#   Number of lines to buffer for filter's regex search when looking for
#   multi-line regex matches.
# @param maxmatches
#   Number of matches stored in ticket.
# @param findtime
#   Time period in seconds during which maxretry number of matches will get an
#   IP banned.
# @param action
#   List of actions that should be used to ban and unban IPs when maxretry
#   matches of failregex has happened for an IP during findtime.
# @param bantime
#   Time period in seconds for which an IP is banned if maxretry matches of
#   failregex happen for the same IP during findtime.
# @param bantime_extra
#   Set of additional optional settings relating to bantime. The keys in this
#   structure are set in the configuration file as `bantime.$key`. See the
#   same parameter in class fail2ban for more details on the possible values.
# @param banaction
#   Name of the action that is extrapolated in default action definitions, or
#   in the action param. This can let you override the action name but keep the
#   default parameters to the action.
# @param banaction_allports
#   Action name that can be extrapolated by some of the default actions. This
#   one is meant to ban all ports at once instead of specific ones. Setting
#   this will change the action for this jail.
# @param chain
#   Name of the iptables chain used by iptables-based actions.
# @param port
#   Comma separated list of ports, port ranges or service names (as found in
#   /etc/services) that should get blocked by the ban action.
# @param protocol
#   Name of the protocol to ban using the action.
# @param mta
#   Program name used for sending out email by actions that do so.
# @param destemail
#   Email address used as recipient by actions that send out emails. Setting
#   this will override destemail for this jail only.
# @param sender
#   Email address set as sender by actions that send out emails.
# @param fail2ban_agent
#   User-agent sent on HTTP requests that are made by some actions.
# @param additional_options
#   Hash of additional values that should be declared for the jail. Keys
#   represent the jail configuration value names and hash values are placed to
#   the right of the "=". This can be used to declare arbitrary values for
#   filters or actions to use. No syntax checking is done on the contents of
#   this hash.
#   Note that any keys in this hash that correspond to a parameter name for
#   this defined type will get overridden by the value that the defined type's
#   parameter was given (e.g. if there is mode => '0600' in additional_options,
#   the value of mode in the file on disk will not take on the value '0600'
#   since there is a resource parameter that already corresponds to this key
#   name).
#
define fail2ban::jail (
  Enum['present','absent']     $ensure             = 'present',
  String                       $config_file_mode   = '0644',
  # Params that override default settings for a particular jail
  Boolean                      $enabled            = true,
  Optional[String]             $mode               = undef,
  Optional[Fail2ban::Backend]  $backend            = undef,
  Optional[Fail2ban::Usedns]   $usedns             = undef,
  Optional[String]             $filter             = undef,
  Array[String]                $logpath            = [],
  Optional[String]             $logencoding        = undef,
  Optional[String]             $logtimezone        = undef,
  Optional[String]             $datepattern        = undef,
  Optional[String[1]]          $prefregex          = undef,
  Optional[Array[String[1]]]   $failregex          = undef,
  Optional[Array[String[1]]]   $ignoreregex        = undef,
  Optional[Boolean]            $ignoreself         = undef,
  Optional[Array[String, 1]]   $ignoreip           = undef,
  Optional[String]             $ignorecommand      = undef,
  Optional[String]             $ignorecache        = undef,
  Optional[Integer[1]]         $maxretry           = undef,
  Optional[Integer[1]]         $maxlines           = undef,
  Optional[Variant[Integer[1], String]] $maxmatches = undef,
  Optional[Fail2ban::Time]     $findtime           = undef,
  Optional[Variant[String, Array[String, 1]]] $action = undef,
  Optional[Fail2ban::Time]     $bantime            = undef,
  Optional[Fail2ban::Bantime_extra] $bantime_extra = undef,
  Optional[String]             $banaction          = undef,
  Optional[String]             $banaction_allports = undef,
  Optional[String]             $chain              = undef,
  Optional[Fail2ban::Port]     $port               = undef,
  Optional[Fail2ban::Protocol] $protocol           = undef,
  Optional[String]             $mta                = undef,
  Optional[String]             $destemail          = undef,
  Optional[String]             $sender             = undef,
  Optional[String]             $fail2ban_agent     = undef,
  Hash[String, String]         $additional_options = {},
) {
  include fail2ban::config

  if $action =~ String {
    deprecation('fail2ban_action_param', 'The $action parameter will only take an array of strings in 5.x')

    $real_action = [$action]
  }
  else {
    $real_action = $action
  }

  if $backend == 'systemd' {
    if ! empty($logpath) {
      fail("The backend for fail2ban jail ${name} is 'systemd' so \$logpath must be empty.")
    }
  }
  else {
    if empty($logpath) {
      fail("You must set \$logpath for fail2ban jail ${name}.")
    }
  }

  if $port == 'all' {
    $portrange = '1:65535'
  }
  else {
    $portrange = $port
  }

  $jail_options = {
    enabled            => $enabled,
    mode               => $mode,
    backend            => $backend,
    usedns             => $usedns,
    filter             => $filter,
    logpath            => $logpath,
    logencoding        => $logencoding,
    logtimezone        => $logtimezone,
    prefregex          => $prefregex,
    failregex          => $failregex,
    ignoreregex        => $ignoreregex,
    ignoreself         => $ignoreself,
    ignoreip           => $ignoreip,
    ignorecommand      => $ignorecommand,
    ignorecache        => $ignorecache,
    maxretry           => $maxretry,
    maxlines           => $maxlines,
    maxmatches         => $maxmatches,
    findtime           => $findtime,
    action             => $real_action,
    bantime            => $bantime,
    bantime_extra      => $bantime_extra,
    banaction          => $banaction,
    banaction_allports => $banaction_allports,
    chain              => $chain,
    port               => $portrange,
    protocol           => $protocol,
    mta                => $mta,
    destemail          => $destemail,
    sender             => $sender,
    fail2ban_agent     => $fail2ban_agent,
  }

  $jail_template_values = {
    jail_name => $name,
    options   => merge($additional_options, $jail_options),
  }
  file { "/etc/fail2ban/jail.d/${name}.conf":
    ensure  => $ensure,
    content => epp('fail2ban/jail.epp', $jail_template_values),
    owner   => 'root',
    group   => 0,
    mode    => $config_file_mode,
    notify  => Class['fail2ban::service'],
  }
}
