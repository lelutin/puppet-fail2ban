# Optional additional bantime.* options. See manifests/init.pp for details
# about what each option means.
#
type Fail2ban::Bantime_extra = Struct[{
  Optional[increment] => Boolean,
  Optional[factor] => String[1],
  Optional[formula] => String[1],
  Optional[multipliers] => String[1],
  Optional[maxtime] => String[1],
  Optional[rndtime] => String[1],
  Optional[overalljails] => Boolean,
}]
