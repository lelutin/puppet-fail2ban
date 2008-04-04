# modules/fail2ban/manifests/init.pp - manage fail2ban stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "fail2ban": }


class fail2ban {
    case $operatingsystem {
        gentoo: {include fail2ban::gentoo}
        default: {include fail2ban::base}
    }
}

class fail2ban::base {

    package{fail2ban:
        ensure => installed,
    }

    service{fail2ban:
        ensure => running,
        enable => true,
        hasstatus => true,
    }

}

class fail2ban::gentoo inherits fail2ban::base {
    Package[fail2ban]{
        category => 'net-analyzer',
    }
    #conf.d file if needed
    Service[fail2ban]{
       require +> File["/etc/conf.d/fail2ban"],
    }
    file { "/etc/conf.d/fail2ban":
        owner => "root",
        group => "0",
        mode  => 644,
        ensure => present,
        source => [
            "puppet://$server/files/fail2ban/conf.d/${fqdn}/fail2ban",
            "puppet://$server/files/fail2ban/conf.d/fail2ban",
            "puppet://$server/fail2ban/conf.d/fail2ban"
        ]
    }
}
