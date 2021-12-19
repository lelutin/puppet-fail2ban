# Where fail2ban's database gets stored. None disables storage
type Fail2ban::Dbfile = Variant[
  Stdlib::Absolutepath,
  Enum['None']
]
