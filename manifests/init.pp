# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
#

class fail2ban {
    case $operatingsystem {
        gentoo: {include fail2ban::gentoo}
        default: {include fail2ban::base}
    }
}
