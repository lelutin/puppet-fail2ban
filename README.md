# Puppet module for fail2ban #

Install and manage fail2ban with puppet to block bruteforce attempts.

To use this module just include the jail2ban class. To change default
configurations in `jail.conf` or `fail2ban.conf`, you can pass values to
parameters to the fail2ban class. See section below for full list of
parameters.

Here's an example that sets default ignored IP address to local host and
another non-routed IP:

~~~
class { 'fail2ban':
  ignoreip => ['127.0.0.1', '10.0.0.1'],
}
~~~

You can create a jail with the `fail2ban::jail` defined type (see section below)
and you can use one of the predefined `fail2ban::jail::*` hiera hashes as
parameters to the `fail2ban::jail` defined type.

You can also create a filter for use with jails with the `fail2ban::filter`
defined type (see section below).

[![Build Status](https://travis-ci.org/lelutin/puppet-fail2ban.svg?branch=master)](https://travis-ci.org/lelutin/puppet-fail2ban)

## Requirements ##

This module depends on the following modules to function:

 * puppetlabs' stdlib module (at least version 4.6.0)

## Compatibility ##

This module supports

 * Debian 8, 9, 10
  * Debian 8 support supposes that clients are using puppet 4.x (e.g. backports
    or upstream packages)
 * Ubuntu 18.04
 * RHEL 6 and 7
 * CentOs 6 and 7

Versions        | Puppet 2.7 | Puppet 3.x | Puppet 4.x | Puppet 5.x |
:---------------|:----------:|:----------:|:----------:|:----------:
**2.x**         | **yes**    | **yes**    | no         | no
**3.x**         | no         | no         | **4.10+**  | **yes**

Version 2.x is in maintenance mode only. If you need to use this module with
puppet 4.x or 5.x then you should use version 3.x of this module.

## Upgrade notices ##

 * 3.2: No pre-defined jail sends out an email as an action by default. Users
     who still want to receive emails when an action is taken can override the
     `action` field from the predefined jail data and append the action the
     following: `\n           %(mta)s-whois[name=%(__name__)s,
     dest=\"%(destemail)s\"]`

     Also note that puppet 4.x prior to 4.10 is not supported anymore, and that
     hiera 5 is now required (hence the limitation for the puppet version.

 * 3.1: `fail2ban.local` and all unmanaged files in `fail2ban.d` are now being
     purged by default. Users who have local modifications that they want to
     keep should set `$rm_fail2ban_local` and/or `$purge_fail2ban_d` to false.

 * 3.0: all of the defined types for predefined jails in `fail2ban::jail::*`
     have been removed and instead transformed into data structures with hiera.
     If you were using the predefined jails, you will need to change your code:
     please take a look at the new method of using them with `lookup()` further
     down in this file.

 * 3.0: `fail2ban::jail`'s `order` parameter was removed. Users should adapt their
     calls in order to remove this parameter. All jail files are now just
     individual files dropped in jail.d and order is not relevant there.

 * 3.0: Deprecation notice: the `persistent_bans` parameter to the `fail2ban`
     class is now deprecated and will be removed for the 4.0 release. fail2ban
     can now manage persistent bans naturally by using its own sqlite3 database.

 * 2.0: Jail definitions have been moved to `jail.d/*.conf` files . The
     `jail.local` file is now getting removed by the module. To
     avoid this, set `rm_jail_local` to true.

 * 2.0: `ignoreip` both on the main class and in `fail2ban::jail` (and thus in
     all `fail2ban::jail::*` classes too) is no longer expected to be a string.
     It is now a list of strings that automatically gets joined with spaces.
     Users of the fail2ban module will need to adjust these parameters.

 * The directory `/etc/fail2ban/jail.d` is now getting purged by default. Users
     who would like to preserve files in this directory that are not managed by
     puppet should now set the `purge_jail_dot_d` parameter to the `fail2ban`
     class to false.

## Parameters to fail2ban class ##

All of the values configured through the `fail2ban` class are used to configure
global default values. These values can be overridden by individual jails.

 * `ignoreip` Default ignored IP(s) when parsing logs. Default value is
   ['127.0.0.1']. Multiple values should be placed in an array.
 * `bantime` Number of seconds during which reaching maxretry gets an IP
   banned. Default value is '600'
 * `findtime` Time interval (in seconds) before the current time where failures
   will count towards a ban. Default is '600'.
 * `maxretry` Number of times an IP address must trigger failgregexes to get
   banned. Default value is '3'
 * `backend` How should fail2ban look for modifications on log files. Default
   value is 'auto'
 * `destemail` Default email address that should get notifications with the
   actions that send emails. Default value is 'root@localhost'
 * `banaction` Default action to use for jails. Default value is
   'iptables-multiport'
 * `mta` Mail Transfer Agent program used for sending out email for actions
   that send out emails. Default value is 'sendmail'
 * `protocol` Default protocol for jails. Default value is 'tcp'
 * `action` Default action for jails. Default value is '%(action_)s', which is
   defined as '%(banaction)s[name=%(__name__)s, port="%(port)s",
   protocol="%(protocol)s]' in jail.conf.
 * `rm_jail_local` Boolean value that decides whether
   `/etc/fail2ban/jail.local` is removed by puppet or not. Defaut value is true.
 * `purge_jail_dot_d` Boolean value that decides whether
   `/etc/fail2ban/jail.d/` is purged of files that are not managed by puppet.
   Default value is true.
 * `usedns` Specifies if jails should trust hostnames in logs. Options are
   yes, warn or no. Default is warn.
 * `persistent_bans` Boolean value that ensure bans persist over time (0.8.x or older).
   This feature is builtin with 0.9.x.
   `/etc/fail2ban/persistent.bans` file is created and populated by
   `/etc/fail2ban/action.d/iptables-multiport.conf`. This parameter is bound to
   be removed in release 4.0 of the module.
   Default value is false.

## Defining jails ##

To define a jail, you can use one of the jail parameter presets (see list
below). Or you can define your own with the `fail2ban::jail` defined type:

~~~
fail2ban::jail { 'jenkins':
  port    => 'all',
  filter  => 'jenkins',
  logpath => '/var/log/jenkins.log',
}
~~~

Here's the full list of parameters you can use:

 * `port` List of port names, separated by commas, that will get blocked for a
   banned IP. Can be "all" to block all ports. This parameter is mandatory.
 * `filter` Name of the filter to use. This parameter is mandatory.
 * `logpath` Path of the log to monitor. This parameter is mandatory unless
   you are using the systemd backend in which case it should not be set.
 * `ensure` Set this to `absent` to remove a jail. This parameter is useless
   with the default value of `purge_jail_dot_d` since removing the jail
   resource will remove the jail file. It can be useful if you set
   `purge_jail_dot_d` to false since then puppet won't automatically remove
   jails that are not managed anymore.
 * `enabled` Should this jail be enabled or not. The subtility between `ensure`
   and this parameter is that ensure will make the contents of the jail appear
   or disappear, while this parameter will let the jail contents be present in
   `jail.local` but the jail will be marked as disabled. Default value is
   'true'
 * `protocol` Override default protocol to ban ports for.
 * `maxretry` Override default number of trials that bans someone.
 * `findtime` Override default interval during which maxretry failures triggers
   a ban.
 * `action` Override default action used.
 * `banaction` Override default `banaction`. If you don't also override
   `action`, you will use the same default action template but with a different
   action name.
 * `bantime` Override default duration of a ban for an IP.
 * `ignoreip` Override default IP(s) to ignore (e.g. don't ban these IPs).
   Multiple values should be placed in an array.
 * `backend` Override default log file following method.

### Predefined jails ###

The list at the end of this section contains all of the presets that can be
used to configure jails more easily. Each of them is a data point -- a hash of
parameter and values -- in hiera that needs to be gathered with the `lookup()`
function. Each hash represents parameters and values that should be passed in
to the `fail2ban::jail` defined type documented above and has a lookup key of
`fail2ban::jail::$jailname`.

For example to configure a jail for the ssh service with the preset parameters:

~~~
$ssh_params = lookup('fail2ban::jail::sshd')
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
~~~

You can also override values from the preset or define new parameters by
concatenating your own hash to it. In the following example we define new
parameters `bantime` and `findtime` and we override the preset for `maxretry`:

~~~
$ssh_extra_params  = {
  'bantime'  => 300,
  'findtime' => 200,
  'maxretry' => 3,
}
$ssh_params = lookup('fail2ban::jail::sshd') + $ssh_extra_params
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
~~~

This way you can set any parameter to the `fail2ban::jail` defined type and
override preset values.

Here's the full list of currently available presets. To know each preset's
default values you can inspect files in `data/`.

Watch out: jails by default use the same filter name as the jail name, so make
sure to either use the same string as the lookup key as the resource name for
`jail`, or override the `filter` parameter.

 * 3proxy
 * apache-auth
 * apache-badbots
 * apache-noscript
 * apache-overflows
 * apache-nohome
 * apache-botsearch
 * apache-fakegooglebot
 * apache-modsecurity
 * apache-shellshock
 * assp
 * asterisk
 * courier-auth
 * courier-smtp
 * cyrus-imap
 * directadmin
 * dovecot
 * dropbear
 * drupal-auth
 * ejabberd-auth
 * exim
 * exim-spam
 * freeswitch
 * froxlor-auth
 * groupoffice
 * gssftpd
 * guacamole
 * horde
 * kerio
 * lighttpd-auth
 * mongodb-auth
 * monit
 * murmur
 * mysql-auth
   * To log wrong MySQL access attempts add to `/etc/mysql/my.cnf` in
     `[mysqld]` or equivalent section: `log-warning = 2`
 * nrpe
 * named-refused
 * nginx-http-auth
 * nginx-limit-req
   * To use 'nginx-limit-req' jail you should have `ngx_http_limit_req_module`
     and define `limit_req` and `limit_req_zone` as described in nginx
     documentation http://nginx.org/en/docs/http/ngx_http_limit_req_module.html
     or for example see in 'config/filter.d/nginx-limit-req.conf'
 * nginx-botsearch
 * nsd
 * openhab-auth
 * openwebmail
 * oracleims
 * pam-generic
 * pass2allow-ftp
 * perdition
 * php-url-fopen
 * postfix
 * postfix-rbl
 * postfix-sasl
 * proftpd
 * pure-ftpd
 * qmail-rbl
 * recidive
   * Ban IPs that get repeatedly banned, but for a longer period of time -- by
     default for one week and one day. Some warnings apply:
   1. Make sure that your loglevel specified in fail2ban.conf/.local
      is not at DEBUG level -- which might then cause fail2ban to fall into
      an infinite loop constantly feeding itself with non-informative lines
   2. Increase dbpurgeage defined in fail2ban.conf to e.g. 648000 (7.5 days)
      to maintain entries for failed logins for sufficient amount of time
 * roundcube-auth
 * selinux-ssh
 * sendmail-auth
 * sieve
 * slapd
 * sogo-auth
 * solid-pop3d
 * squid
 * squirrelmail
 * sshd
 * sshd-ddos
 * stunnel
   * This pre-defined jail does not specify ports to ban since this service can
     run on many choices of ports. By default this means that all ports will be
     blocked for IPs that are banned by this jail. You may want to override the
     hash to add in specific ports in the `port` parameter.
 * suhosin
 * tine20
 * uwimap-auth
 * vsftpd
 * webmin-auth
 * wuftpd
 * xinetd-fail
   * This pre-defined jail does not specify ports to ban since this service can
     run on many choices of ports. By default this means that all ports will be
     blocked for IPs that are banned by this jail. You may want to override the
     hash to add in specific ports in the `port` parameter.

## Defining filters ##

You might want to define new filters for your new jails. To do that, you can
use the `fail2ban::filter` defined type:

~~~
fail2ban::filter { 'jenkins':
  failregexes => [
    # Those regexes are really arbitrary examples.
    'Invalid login to Jenkins by user mooh by IP \'<HOST>\'',
    'Forced entry trial by <HOST>',
  ],
}
~~~

Here's the full list of parameters you can use with the defined type:

 * `failregexes` List of regular expressions (strings) that, if matched, will
   increase IP's maxretry count. This parameter is mandatory.
 * `ensure` Should this filter be present or not. Default value is present
 * `ignoreregexes` List of regular expressions (strings) that, if matched, will
   invalidate failregex matching. Default value is an empty list.
 * `includes` List of file names that should be included before the filter
   definition. An `[INCLUDES]` section will be added to the top of the filter
   configuration file, and the file names in this list will be added to a
   `before =` line.
 * `includes_after` List of file names that should be included after the filter
   definition. An `[INCLUDES]` section will be added to the top of the filter
   configuration file, and the file names in this list will be added to an
   `after =` line.
 * `additional_defs` List of lines that could define more arbitrary values.
   Lines will be placed in the file as they are in the list. Default value is
   an empty list.

## nftables support ##

Fail2ban supports nftables with the `nftables-multiport` and
`nftables-allports` actions. Since nftables is now used by default since
debian buster, here's how to quickly enable usage of nftables for fail2ban:

Only two parameters need to be changed.

 * `chain` needs to be set to lowercase
 * `banaction` needs to be set to the action of your choice.

Here's an example minimal configuration for using nftables:

~~~
class { 'fail2ban':
  banaction      => 'nftables-multiport',
  chain          => 'input',
}
$ssh_params = lookup('fail2ban::jail::sshd')
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
~~~

Do note that upon service restart, fail2ban will not create the ip set and the
corresponding rule right away. They will only be added whenever the first
"action" is taken (so when banning the first IP for a jail). After that you
should see both the set and the rule for that jail when running
`nft list ruleset`.

## Running tests ##

This module has some tests that you can run to ensure that everything is
working as expected.

### Unit tests ###

The unit tests are built with rspec-puppet. You can use the Gemfile with the
`tests` group to install what's needed to run the unit test.

The usual rspec-puppet_helper rake tasks are available. You can also use a
convenience task `tests` to run everything. The following two commands achieve
the same result:

    rake syntax lint spec
    rake tests

### Funtionality testing ###

Unit tests are great, but sometimes it's nice to actually run the code in order
to see if everything is setup properly and that the software is working as
expected.

This repository has a `Vagrantfile` that you can use to bring up a VM and run
this module inside. The `Vagrantfile` expects you to have the vagrant plugin
`vagrant-librarian-puppet` installed. If you don't have it you can also
download this module's requirements (see `metadata.json`) and place them inside
`tests/modules/`.

A couple of manifest files inside `tests/` prepare sets of use cases. You can
modify the `Vagrantfile` to use any of them for provisioning the VM.

