# Backend names that fail2ban understands
# Can be one of the pre-defined backend names or a python-style variable
type Fail2ban::Backend = Variant[Enum['auto','pyinotify','gamin','polling','systemd'], Pattern[/%\(\w+\)s/]]
