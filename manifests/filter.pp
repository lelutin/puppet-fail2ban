# fail2ban/manifests/filter.pp
#
# - Copyright (C) 2014-2018 gabster@lelutin.ca
#
# Filters are how fail2ban detects mischief in logs. They contain regular
# expressions that should catch bad activity and identify the IP that is doing
# this activity.
#
# @summary Setup a filter for fail2ban
#
# @api public
#
#
# @example defining filter for jenkins
#   fail2ban::filter { 'jenkins':
#     failregexes => [
#       # Those regexes are really arbitrary examples.
#       'Invalid login to Jenkins by user mooh by IP \'<HOST>\'',
#       'Forced entry trial by <HOST>',
#     ],
#   }
#
#
# @param failregexes
#   List of regular expressions that will be run against new log lines as they
#   reach fail2ban. The regular expressions follow the Python regular
#   expression format, and there are some special patterns that fail2ban can
#   use. See the jail.conf(5) man page for more details. Each item in the list
#   is placed on its own line. Lines starting with the second one are prepended
#   with spaces so that the regular expressions line up with the beginning of
#   the first one.
# @param ensure
#   Whether the resources should be installed or removed.
# @param config_file_mode
#   Permission mode given to the filter file created by this defined type.
# @param ignoreregexes
#   List of Python regular expressions that should prevent a log line from
#   being considered for banning. If a line matches regular expressions
#   contained in this parameter, they are ignored even though they would have
#   matched a failregex. Each item in the list is placed on its own line. Lines
#   starting with the second one are prepended with spaces so that the regular
#   expressions line up with the beginning of the first one.
# @param includes
#   List of files to include before considering the rest of the filter
#   definition. These files can declare variables used by the filter to set
#   default behaviours.
# @param includes_after
#   List of files to include after filter definition.
# @param additional_defs
#   List of arbitrary lines that should appear at the begining of the filter's
#   definition section, for anything that didn't fit in other parameters. Each
#   item in the list is output on its own line in the filter file. No syntax
#   checking is done.
#
define fail2ban::filter (
  Array[String, 1] $failregexes,
  Enum['present', 'absent'] $ensure = 'present',
  String           $config_file_mode = '0644',
  Array[String, 0] $ignoreregexes = [],
  Array[String, 0] $includes = [],
  Array[String, 0] $includes_after = [],
  Array[String, 0] $additional_defs = []
) {
  include fail2ban::config

  file { "/etc/fail2ban/filter.d/${name}.conf":
    ensure  => $ensure,
    content => template('fail2ban/filter.erb'),
    owner   => 'root',
    group   => 0,
    mode    => $config_file_mode,
    require => Class['fail2ban::config'],
    notify  => Class['fail2ban::service'],
  }

}
