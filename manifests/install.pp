# Install fail2ban
#
# This class should not be included directly. Users must use the fail2ban
# class.
class fail2ban::install {

  ensure_packages(['fail2ban'])

}
