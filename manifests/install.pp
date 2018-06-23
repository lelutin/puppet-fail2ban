# fail2ban/manifests/install.pp
#
# This class should not be included directly. Users must use the fail2ban
# class.
#
# @summary Install fail2ban
#
# @api private
#
class fail2ban::install {

  ensure_packages(['fail2ban'])

}
