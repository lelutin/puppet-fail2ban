class fail2ban::jail::asterisk (
  $maxretry = 'usedefault',
  $findtime = false,
  $ignoreip = false
) {

  $real_maxretry = $maxretry ? {
    'usedefault' => '6',
    default      => $maxretry
  }

  fail2ban::filter { 'asterisk':
    failregexes   => [
      'NOTICE.* .*: Registration from \'.*\' failed for \'<HOST>:.*\' - Wrong password',
      'NOTICE.* .*: Registration from \'\".*\".*\' failed for \'<HOST>:.*\' - Wrong password',
      'NOTICE.* .*: Registration from \'.*\' failed for \'<HOST>:.*\' - No matching peer found',
      'NOTICE.* .*: Registration from \'.*\' failed for \'<HOST>:.*\' - Username/auth name mismatch',
      'NOTICE.* .*: Registration from \'.*\' failed for \'<HOST>:.*\' - Device does not match ACL',
      'NOTICE.* .*: Registration from \'.*\' failed for \'<HOST>:.*\' - Peer is not supposed to register',
      'NOTICE.* <HOST> failed to authenticate as \'.*\'$',
      'NOTICE.* .*: No registration for peer \'.*\' \(from <HOST>\)',
      'NOTICE.* .*: Host <HOST> failed MD5 authentication for \'.*\' (.*)',
      'NOTICE.* .*: Failed to authenticate user .*@<HOST>.*',
      'NOTICE.* .*: Call from \'.*\' \(<HOST>:.*\) to extension \'.*\' rejected because extension not found in context \'.*\'\.',
    ],
  }
  fail2ban::jail { 'asterisk':
    enabled  => true,
    port     => 'iax,sip,sip-tls',
    filter   => 'asterisk',
    logpath  => '/var/log/asterisk/messages',
    maxretry => $real_maxretry,
    require  => Fail2ban::Filter['asterisk'],
    findtime => $findtime,
    ignoreip => $ignoreip,
  }

}
