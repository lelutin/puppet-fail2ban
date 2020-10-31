# Puppet module for fail2ban #

___Table of contents___:

1. [Overview](#overview)
1. [Module description](#module-description)
1. [Usage](#usage)
    1. [Defining jails](#defining-jails)
        1. [Predefined jails](#predefined-jails)
    1. [Defining filters](#defining-filters)
    1. [Defining actions](#defining-actions)
        1. [nftables support](#nftables-support)
1. [Requirements](#requirements)
1. [Compatibility](#compatibility)
1. [Upgrade notices](#upgrade-notices)
1. [Documentation](#documentation)
1. [Testing](#testing)
    1. [Unit tests](#unit-tests)
    1. [Functionality tests](#functionality-tests)

## Overview ##

Install and manage fail2ban with puppet to block bruteforce attempts.

## Module description ##

With this module, you can install fail2ban and define any configuration for
the service in order to slow down bruteforce attempts on services that need to
be exposed to the internet.

This module lets you create:

 * actions (e.g. what to do when there's a problematic case)
 * filters (e.g. how to discover problematic cases)
 * jails (e.g. combining actions and filters with a rate limit on filter
     matches)

[![Build Status](https://travis-ci.org/lelutin/puppet-fail2ban.svg?branch=master)](https://travis-ci.org/lelutin/puppet-fail2ban)

## Usage ##

To use this module just include the fail2ban class.

To change default configurations in `jail.conf` or `fail2ban.conf`, you can
pass values to parameters to the fail2ban class. See technical reference
documentation for full list of parameters.

Here's an example that sets default ignored IP address for all jails to
localhost and another non-routed IP:

~~~
class { 'fail2ban':
  ignoreip => ['127.0.0.1', '10.0.0.1'],
}
~~~

### Defining jails ###

To define a jail, you can use one of the jail parameter presets (see list
below). Or you can define your own with the `fail2ban::jail` defined type:

~~~
fail2ban::jail { 'jenkins':
  port    => 'all',
  filter  => 'jenkins',
  logpath => '/var/log/jenkins.log',
}
~~~

#### Predefined jails ####

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

### Defining filters ###

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

### Defining actions ###

Fail2ban can do pretty much what you want it to do when an IP matches a filter
enough times during the rate limit set by the jail using both the filter and
actions.

To define a new action, you can use the `fail2ban::action` defined type.
Here's an example that would call out to a fictitious REST API whenever an IP
address is banned and unbanned:

~~~
fail2ban::action { 'rest_api':
  ensure      => present,
  actionban   => ['curl -s -X PUT http://yourapi:8080/theapi/v4/firewall/rules -H "Content-Type:application/json" -H "Authorization: ..." -d "{\"ban\": \"<ip>\"}"'],
  actionunban => ['curl -s -X DELETE http://yourapi:8080/theapi/v4/firewall/rules/1 -H "Authorization: ..."'],
}
~~~

#### nftables support ####

Fail2ban supports nftables with the `nftables-multiport` and
`nftables-allports` actions that are shipped with the fail2ban binary. These
actions use nftables' `set` functionality to contain banned IPs instead of
adding a firewall rule for each new banned IP. This should make your firewall
more efficient if you have lots of banned IPs.

Since nftables is now used by default on Debian since the buster release (but
`iptables` is still used by fail2ban's default action), here's how to quickly
enable usage of nftables for fail2ban:

Only two global parameters need to be changed:

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

To list which IPs are currently banned, you can either use `fail2ban-client
status sshd` or list elements of the corresponding set: `nft list set
filter f2b-sshd`

## Requirements ##

This module depends on the following modules to function:

 * puppetlabs' stdlib module (at least version 4.6.0)

## Compatibility ##

This module supports

 * Debian 8, 9, 10
  * Debian 8 support supposes that clients are using puppet 4.x (e.g. backports
    or upstream packages)
 * Ubuntu 18.04
 * RHEL 6, 7 and 8
 * CentOs 6, 7 and 8

Versions        | Puppet 2.7 | Puppet 3.x | Puppet 4.x | Puppet 5.x |
:---------------|:----------:|:----------:|:----------:|:----------:
**3.x**         | no         | no         | **4.10+**  | **yes**

## Upgrade notices ##

 * 3.3: Support for the 2.x branch was discontinued. Only puppet 4.x+ is
     supported from now on.

     Documentation in the `README.md` file is now limited to only examples of
     how to use the module. For a technical reference of all classes, defined
     types and their parameters, please refer to REFERENCE.md or generate html
     documentation with puppet-strings.

     Note that debian 8 is still being supported for a little while, but with
     the expectation that users use this module with puppet 4.x+. Debian 8's
     support cycle is almost over, thus so it is for this module. Expect
     support to be removed from this module in the coming months.

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

## Documentation ##

This module uses puppet-strings comments, so you can generate HTML
documentation in the `docs` directory with the following command:

~~~
puppet strings generate manifests
~~~

At each release, technical documentation about all classes and defined types
provided by this module and their parameters is also output to the
`REFERENCES.md` file in this repository in markdown format with the following
command. This makes the reference documentation show up on forge.puppet.com
and you can consult it after cloning the repository even if you don't have
puppet-strings installed:

~~~
puppet strings generate --format markdown
~~~

## Testing ##

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

### Funtionality tests ###

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

