# Configure a filter for fail2ban
#
# The failregexes, ignoreregexes, includes, includes_after and additional_defs
# arguments need to be arrays
#
define fail2ban::filter (
  Array[String, 1] $failregexes,
  Enum['present', 'absent'] $ensure = 'present',
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
    mode    => '0644',
    require => Class['fail2ban::config'],
    notify  => Class['fail2ban::service'],
  }

}
