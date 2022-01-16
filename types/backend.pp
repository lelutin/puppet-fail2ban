# Backend names that fail2ban understands
# Can be one of the pre-defined backend names, "systemd" with optionally a list
# of parameters between square brackets or a python-style variable
type Fail2ban::Backend = Variant[
  Enum['auto','pyinotify','gamin','polling'],
  Pattern[/^systemd(\[.*\]$)?/],
  Pattern[/%\(\w+\)s/],
]
