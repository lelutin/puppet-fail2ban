# fail2ban/manifests/service.pp
#
# This class should not be included directly. Users must use the fail2ban
# class.
#
# @summary Enable fail2ban daemon
#
# @api private
#
class fail2ban::service {

  service { 'fail2ban':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

}
