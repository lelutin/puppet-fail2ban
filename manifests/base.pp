class fail2ban::base {
  package{'fail2ban': ensure => installed }

  service{'fail2ban':
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package['fail2ban']
  }
}

