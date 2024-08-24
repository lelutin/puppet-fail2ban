# This test file runs just the most basic fail2ban setup

# This is required when running tests with the puppet/puppet-agent-ubuntu
# docker image -- otherwise fail2ban fails to install.
exec { 'update apt archive':
  command => '/usr/bin/apt-get update',
}

class { 'fail2ban':
}

$ssh_params = lookup('fail2ban::jail::sshd')
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
