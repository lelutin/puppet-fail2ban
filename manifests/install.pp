class fail2ban::install {

  $fail2ban_package = $::osfamily ? {
    /(Debian|RedHat)/     => 'fail2ban',
    /(DragonFly|FreeBSD)/ => 'py27-fail2ban',
    default               => 'fail2ban',
  }

  ensure_packages($fail2ban_package)

  if $::operatingsystem == 'gentoo' {
    Package['fail2ban'] {
      category => 'net-analyzer',
    }
  }

}
