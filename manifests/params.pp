# fail2ban::params
#
# @summary Default values for params of the main class
#
class fail2ban::params {

  case $facts['os']['family'] {
    'Debian': {
      if $facts['os']['release']['major'] == 8 {
        # Keep this special case so that jessie hosts with puppet 4.x from
        # backports can still configure fail2ban 0.8 as distributed in that
        # release.
        $jail_conf_template = "${module_name}/debian/jessie-jail.conf.erb"
      }
      else {
        $jail_conf_template = "${module_name}/debian/jail.conf.erb"
      }
    }
    'RedHat': {
      $jail_conf_template = "${module_name}/rhel/jail.conf.erb"
    }
    default: { fail("Unsupported Operating System family: ${facts['os']['family']}") }
  }

}
