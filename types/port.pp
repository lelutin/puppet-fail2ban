# Possible values for the port parameter
# ports can be specified by number, but you can also pass in a comma-separated
# list of values in a string.
# The values in the string can be port numbers (integers), a range of port
# numbers in the format 'number:number', service names (looked up in
# /etc/services) or 'all' which is translated to '0:65535'
type Fail2ban::Port = Variant[Integer, String]
