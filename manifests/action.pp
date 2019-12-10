# fail2ban/manifests/action.pp
#
# - Copyright (C) 2014-2019 gabster@lelutin.ca
#
# Actions define what fail2ban should do when if finds mischief happening in
# logs. Usually, an action defines commands that should be run during
# setup/teardown and commands for when a ban or an unban happen. Using action
# you can make fail2ban whatever you want, from creating an iptables rule to
# calling out to your edge server API to create a rule there instead.
#
# @summary Create an action for fail2ban
#
# @api public
#
# @see jail.conf(5)
#
#
# @example defining a new action to call out to a REST API
#   fail2ban::action { 'rest_api':
#     ensure      => present,
#     actionban   => ['curl -s -X PUT http://yourapi:8080/theapi/v4/firewall/rules -H "Content-Type:application/json" -H "Authorization: ..." -d "{\"ban\": \"<ip>\"}"'],
#     actionunban => ['curl -s -X DELETE http://yourapi:8080/theapi/v4/firewall/rules/1 -H "Authorization: ..."'],
#   }
#
#
# @param actionban
#   List of commands that are executed when fail2ban has found too many
#   matches for a given IP address.
# @param actionunban
#   List of commands that are executed after `bantime` has elapsed.
# @param ensure
#   Whether the resources should be installed or removed.
# @param actioncheck
#   List of commands that are run by fail2ban before any other action to
#   verify that the environment (or setup) is still in good shape.
# @param actionstart
#   List of commands that are executed when the jail is started.
# @param actionstop
#   List of commands that are executed when the jail is stopped.
# @param config_file_mode
#   Permission mode given to the filter file created by this defined type.
# @param includes
#   List of files to include before considering the rest of the action
#   definition. These files can declare variables used by the action to set
#   default or common behaviours.
# @param includes_after
#   List of files to include after action definition.
# @param additional_defs
#   List of arbitrary lines that should appear at the begining of the action's
#   definition section, for anything that didn't fit in other parameters. Each
#   item in the list is output on its own line in the action file. No syntax
#   checking is done.
# @param init
#   List of arbitrary lines that will be a part of the [Init] section. All
#   tags (variables) defined in this section can be overridden by any
#   individual jail to change the action's behaviour.
#
define fail2ban::action (
  Array[String[1], 1] $actionban,
  Array[String[1], 1] $actionunban,
  Enum['present', 'absent'] $ensure = 'present',
  Array[String[1]]    $actioncheck = [],
  Array[String[1]]    $actionstart = [],
  Array[String[1]]    $actionstop  = [],
  String              $config_file_mode = '0644',
  Array[String]       $includes = [],
  Array[String]       $includes_after = [],
  Array[String]       $additional_defs = [],
  Array[String]       $init = [],
) {
  require fail2ban::config

  $action_args = {
    includes        => $includes,
    includes_after  => $includes_after,
    additional_defs => $additional_defs,
    actioncheck     => $actioncheck,
    actionstart     => $actionstart,
    actionstop      => $actionstop,
    actionban       => $actionban,
    actionunban     => $actionunban,
    init            => $init,
  }

  file { "/etc/fail2ban/action.d/${name}.conf":
    ensure  => $ensure,
    content => epp('fail2ban/action.epp', $action_args),
    owner   => 'root',
    group   => 0,
    mode    => $config_file_mode,
    notify  => Class['fail2ban::service'],
  }
}
