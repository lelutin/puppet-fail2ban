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
#     findtime   => 300,
#     maxretry   => 1,
#     port       => 'all',
#     logpath    => ['/var/log/honeypot.log'],
#   }
#
# @example using a pre-defined jail
#   $ssh_params = lookup('fail2ban::jail::sshd')
#   fail2ban::jail { 'sshd':
#     *          => $ssh_params,
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
#     *          => $ssh_params,
#   }
#
#
# @param ensure
#   Whether resources for the defined jail should be installed or removed.
# @param enabled
#   Whether or not a jail is enabled. Setting this to false makes it possible
#   to keep configuration around for a certain jail but temporarily disable it.
# @param config_file_mode
#   Permission mode given to the jail file created by this defined type.
#
# @param port
#   Comma separated list of ports, port ranges or service names (as found in
#   /etc/services) that should get blocked by the ban action.
# @param mode
#   Change the behavior of the filter used by this jail. The mode will
#   generally determine which regular expressions the filter will include. The
#   values that this can take are determined by each individual filter. To know
#   exactly which values are available in filters, you need to read their
#   configuration files.
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
# @param protocol
#   Name of the protocol to ban using the action.
# @param maxretry
#   Number of failregex matches during findtime after which an IP gets banned.
# @param findtime
#   Time period in seconds during which maxretry number of matches will get an
#   IP banned.
# @param ignorecommand
#   Command used to determine if an IP should found by a failregex be ignored.
#   This can be used to have a more complex and dynamic method of listing and
#   identifying IPs that should not get banned. It can be used also when
#   ignoreip is present.
# @param action
#   List of actions that should be used to ban and unban IPs when maxretry
#   matches of failregex has happened for an IP during findtime.
# @param usedns
#   Whether or not to resolve DNS hostname of IPs that have been found by a
#   failregex.
# @param banaction
#   Name of the action that is extrapolated in default action definitions, or
#   in the action param. This can let you override the action name but keep the
#   default parameters to the action.
# @param bantime
#   Time period in seconds for which an IP is banned if maxretry matches of
#   failregex happen for the same IP during findtime.
# @param ignoreip
#   List of IPs or CIDR prefixes to ignore when identifying matches of
#   failregex. The IPs that fit the descriptions in this parameter will never
#   get banned by the jail.
# @param backend
#   Method used by fail2ban to obtain new log lines from the log file(s) in
#   logpath.
# @param additional_options
#   Hash of additional values that should be declared of the jail. Keys are the
#   value name and values are placed to the right of the "=". This can be used
#   to declare arbitrary values for filters or actions to use. No syntax
#   checking is done on the contents of this hash.
#
define fail2ban::jail (
  Enum['present','absent']     $ensure             = 'present',
  Boolean                      $enabled            = true,
  String                       $config_file_mode   = '0644',
  # Params that override default settings for a particular jail
  Optional[Fail2ban::Port]     $port               = undef,
  Optional[String]             $mode               = undef,
  Optional[String]             $filter             = undef,
  Array[String]                $logpath            = [],
  Optional[String]             $logencoding        = undef,
  Optional[Fail2ban::Protocol] $protocol           = undef,
  Optional[Integer]            $maxretry           = undef,
  Optional[Integer]            $findtime           = undef,
  Optional[String]             $ignorecommand      = undef,
  Optional[Variant[String, Array[String, 1]]] $action = undef,
  Optional[Fail2ban::Usedns]   $usedns             = undef,
  Optional[String]             $banaction          = undef,
  Optional[Integer]            $bantime            = undef,
  Array[String, 0]             $ignoreip           = [],
  Optional[Fail2ban::Backend]  $backend            = undef,
  Hash[String, String]         $additional_options = {},
) {
  include fail2ban::config

  if $action =~ String {
    deprecation('fail2ban_action_param',
      'The $action parameter will only take an array of strings in 5.x')
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
  else
  {
    $portrange = $port
  }

  $jail_options = {
    jail_name          => $name,
    enabled            => $enabled,
    port               => $portrange,
    mode               => $mode,
    filter             => $filter,
    logpath            => $logpath,
    logencoding        => $logencoding,
    protocol           => $protocol,
    maxretry           => $maxretry,
    findtime           => $findtime,
    ignorecommand      => $ignorecommand,
    action             => $action,
    usedns             => $usedns,
    banaction          => $banaction,
    bantime            => $bantime,
    ignoreip           => $ignoreip,
    backend            => $backend,
    additional_options => $additional_options,
  }

  file { "/etc/fail2ban/jail.d/${name}.conf":
    ensure  => $ensure,
    content => epp('fail2ban/jail.epp', $jail_options),
    owner   => 'root',
    group   => 0,
    mode    => $config_file_mode,
    notify  => Class['fail2ban::service']
  }

}
