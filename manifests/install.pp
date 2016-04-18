class fail2ban::install {

  ensure_packages(['fail2ban'])

  if $::operatingsystem == 'gentoo' {
    Package['fail2ban'] {
      category => 'net-analyzer',
    }
  }

}
