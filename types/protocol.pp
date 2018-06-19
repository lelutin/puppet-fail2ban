# Options for protocol type
# This is used by the default action iptables-multiport to defined what
# protocol to ban for the specified ports.
type Fail2ban::Protocol = Enum['tcp','udp','icmp','all']
