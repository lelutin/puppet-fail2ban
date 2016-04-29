# Configure a filter for fail2ban
#
# The failregexes, ignoreregexes and additional_defs arguments need to be arrays
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

  if !is_array($includes) {
    fail('includes must be an array')
  }

  if !is_array($includes_after) {
    fail('includes_after must be an array')
  }

  file { "/etc/fail2ban/filter.d/${name}.conf":
    ensure  => $ensure,
    content => template('fail2ban/filter.erb'),
    owner   => 'root',
    group   => 0,
    mode    => '0644',
  }

}
