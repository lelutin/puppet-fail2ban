# Configure a filter for fail2ban
#
# The failregexes, ignoreregexes, includes, includes_after and additional_defs
# arguments need to be arrays
#
define fail2ban::filter (
  $failregexes,
  $ensure    = present,
  $ignoreregexes = [],
  $includes = [],
  $includes_after = [],
  $additional_defs = []
) {
  include fail2ban::config

  validate_array($ignoreregexes)
  validate_array($includes)
  validate_array($includes_after)
  validate_array($additional_defs)

  file { "/etc/fail2ban/filter.d/${name}.conf":
    ensure  => $ensure,
    content => template('fail2ban/filter.erb'),
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    require => Class['fail2ban::config'],
    notify  => Class['fail2ban::service'],
  }

}
