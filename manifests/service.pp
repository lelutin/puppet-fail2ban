# Enable fail2ban daemon
#
# This class should not be included directly. Users must use the fail2ban
# class.
class fail2ban::service {

  service { 'fail2ban':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

}
