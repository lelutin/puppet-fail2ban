# This test file runs just the most basic fail2ban setup
class { 'fail2ban':
}

$ssh_params = lookup('fail2ban::jail::sshd')
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
