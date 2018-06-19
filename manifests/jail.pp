# Setup a fail2ban jail.
#
define fail2ban::jail (
  Enum['present','absent']     $ensure             = 'present',
  Optional[Fail2ban::Port]     $port               = undef,
  Optional[String]             $filter             = undef,
  Optional[String]             $logpath            = undef,
  Boolean                      $enabled            = true,
  Optional[Fail2ban::Protocol] $protocol           = undef,
  Optional[Integer]            $maxretry           = undef,
  Optional[Integer]            $findtime           = undef,
  Optional[String]             $ignorecommand      = undef,
  Optional[String]             $action             = undef,
  Optional[Fail2ban::Usedns]   $usedns             = undef,
  Optional[String]             $banaction          = undef,
  Optional[Integer]            $bantime            = undef,
  Array[String, 0]             $ignoreip           = [],
  Optional[Fail2ban::Backend]  $backend            = undef,
  Hash[String, String]         $additional_options = {},
) {
  include fail2ban::config

  if $backend == 'systemd' {
    if $logpath {
      fail('logpath must not be set when $backend is \'systemd\'')
    }
  }
  else {
    if $logpath == false {
      fail('logpath must be set unless $backend is \'systemd\'')
    }
  }

  if $port == 'all' {
    $portrange = '1:65535'
  }
  else
  {
    $portrange = $port
  }

  file { "/etc/fail2ban/jail.d/${name}.conf":
    ensure  => $ensure,
    content => template('fail2ban/jail.erb'),
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    notify  => Class['fail2ban::service']
  }

}
