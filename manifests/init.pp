# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
#

class fail2ban {

  anchor { 'fail2ban::begin': } ->
  class { 'fail2ban::install': } ->
  class { 'fail2ban::config': } ~>
  class { 'fail2ban::service': } ->
  anchor { 'fail2ban::end': }

}
