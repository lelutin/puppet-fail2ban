# Where logs are sent
type Fail2ban::Logtarget = Variant[
  Stdlib::Absolutepath,
  Enum['SYSLOG', 'STDERR', 'STDOUT']
]
