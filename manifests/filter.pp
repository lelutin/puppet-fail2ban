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
# @see https://fail2ban.readthedocs.io/en/latest/filters.html
# @see https://github.com/fail2ban/fail2ban/blob/0.11/man/jail.conf.5 jail.conf(5)
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
# @param init
#   List of arbitrary lines that should appear in the optional filter
#   Init section. Variable definitions in the Init section can be overridden by
#   users in *.local files. Each item in the list is output on its own line in
#   the filter file. No syntax checking is done.
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
# @param prefregex
#   If this is set, it contains a regular expression that should be used to
#   parse (after datepattern found a match) a common part to all messages that
#   can then match a smaller failregex or ignoreregex. If this regex does not
#   match, then failregex or ignoreregex are not even tried.
# @param ignoreregexes
#   List of Python regular expressions that should prevent a log line from
#   being considered for banning. If a line matches regular expressions
#   contained in this parameter, they are ignored even though they would have
#   matched a failregex. Each item in the list is placed on its own line. Lines
#   starting with the second one are prepended with spaces so that the regular
#   expressions line up with the beginning of the first one.
# @param maxlines
#   Maximum number of lines that fail2ban should buffer for matching
#   multi-line regexes.
# @param datepattern
#   Custom date pattern/regex for the log file. This is useful if dates use a
#   non-standard formatting.
# @param journalmatch
#   If the log backend is set to systemd, this specifies a matching pattern to
#   filter journal entries.
#
define fail2ban::filter (
  Array[String, 1] $failregexes,
  Enum['present', 'absent'] $ensure = 'present',
  String           $config_file_mode = '0644',
  # general configuration
  Array[String]    $init = [],
  Array[String, 0] $includes = [],
  Array[String, 0] $includes_after = [],
  # main filter definition
  Array[String, 0] $additional_defs = [],
  Optional[String] $prefregex = undef,
  Array[String, 0] $ignoreregexes = [],
  Optional[Integer[1]] $maxlines = undef,
  Optional[String] $datepattern = undef,
  Optional[String] $journalmatch = undef,
) {
  include fail2ban::config

  $filter_options = {
    init            => $init,
    includes        => $includes,
    includes_after  => $includes_after,
    additional_defs => $additional_defs,
    prefregex       => $prefregex,
    failregexes     => $failregexes,
    ignoreregexes   => $ignoreregexes,
    maxlines        => $maxlines,
    datepattern     => $datepattern,
    journalmatch    => $journalmatch,
  }

  file { "/etc/fail2ban/filter.d/${name}.conf":
    ensure  => $ensure,
    content => epp('fail2ban/filter.epp', $filter_options),
    owner   => 'root',
    group   => 0,
    mode    => $config_file_mode,
    require => Class['fail2ban::config'],
    notify  => Class['fail2ban::service'],
  }

}
