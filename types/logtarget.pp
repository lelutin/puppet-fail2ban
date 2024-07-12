# Where logs are sent
type Fail2ban::Logtarget = Variant[
  Stdlib::Absolutepath,
  Enum['STDOUT', 'STDERR', 'SYSLOG', 'SYSOUT', 'SYSTEMD-JOURNAL']
]
