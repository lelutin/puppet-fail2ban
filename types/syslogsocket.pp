# Path to a socket for communication with syslog, or 'auto' for letting
# fail2ban auto-discover the path.
type Fail2ban::Syslogsocket = Variant[Stdlib::Absolutepath, Enum['auto']]
