class fail2ban::install {

  package { 'fail2ban': ensure => installed }

  if $::operatingsystem == 'gentoo' {
    Package['fail2ban'] {
      category => 'net-analyzer',
    }
  }

}
