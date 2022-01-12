# Time in seconds for some configuration options can be specified either in an
# integer number of seconds, or an abbreviation that can help specify some time
# periods more easily
#
# Time abbreviation can be combined to make a more precise amount. For example
# 1d3h20m
#
# @see https://github.com/fail2ban/fail2ban/blob/master/man/jail.conf.5 jail.conf(5)
#
type Fail2ban::Time = Variant[
  Integer[1],
  Pattern[/^(\d+(ye(a(r(s)?)?)?|yy?|mo(n(th(s)?)?)?|we(e(k(s)?)?)?|ww?|da(y(s)?)?|dd?|ho(u(r(s)?)?)?|hh?|mi(n(ute(s)?)?)?|mm?|se(c(ond(s)?)?)?|ss?))+$/],  # lint:ignore:140chars
]
