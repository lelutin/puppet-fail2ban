# Puppet module for fail2ban #

___Table of contents___:

1. [Overview](#overview)
2. [Module description](#module-description)
3. [Usage](#usage)
   * [Defining jails](#defining-jails)
     * [Predefined jails](#predefined-jails)
   * [Defining filters](#defining-filters)
   * [Defining actions](#defining-actions)
     * [Python action scripts](#python-action-scripts)
     * [nftables support](#nftables-support)
4. [Requirements](#requirements)
5. [Compatibility](#compatibility)
6. [Upgrade notices](#upgrade-notices)
7. [Documentation](#documentation)
8. [Testing](#testing)
   * [Unit tests](#unit-tests)
   * [Funtionality tests](#funtionality-tests)

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

## Usage ##

To use this module just include the `fail2ban` class.

To change default configurations in `jail.conf` or `fail2ban.conf`, you can
pass values to parameters to the `fail2ban` class. See technical reference
documentation (REFERENCE.md) for full list of parameters.

Here's an example that sets default ignored IP address for all jails to
localhost plus another rfc1819 IP:

~~~puppet
class { 'fail2ban':
  ignoreip => ['127.0.0.1', '10.0.0.1'],
}
~~~

### Defining jails ###

The `fail2ban::jail` defined type lets you configure jails. This is the
resource you'll mostly likely be using the most.

You can use one of the jail parameter presets (see details and list of presets
in the section below. for more details the presets are defined in hiera files
in `data/`) to speed up defining some common jails.

The following example defines a jail for the jenkins service:

~~~puppet
fail2ban::jail { 'jenkins':
  port    => 'all',
  filter  => 'jenkins',
  logpath => ['/var/log/jenkins.log'],
}
~~~

#### Predefined jails ####

The list at the end of this section contains all of the presets that can be
used to configure jails more easily.

Each of them is a data point -- a hash of parameter and values -- in hiera that
needs to be gathered with the `lookup()` function.

Each hash represents parameters and values that should be passed in
to the `fail2ban::jail` defined type (so they are really just presets for the
type's parameters) documented above and has a lookup key of
`fail2ban::jail::$jailname`.

For example, to quickly configure a jail for the ssh service with the preset
parameters:

~~~puppet
$ssh_params = lookup('fail2ban::jail::sshd')
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
~~~

You can also override values from the preset or define new parameters by
concatenating your own hash to it. In the following example we define new
parameters `bantime` and `findtime` and we override the preset for `maxretry`:

~~~puppet
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

Watch out: jails by default use the same filter name as the jail name, so make
sure to either use the same string as the lookup key for the `jail` resource
name, or override the `filter` parameter.

Here's the full list of currently available presets. To know each preset's
default values you can inspect files in `data/`:

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
* bitwarden
* centreon
* counter-strike
* courier-auth
* courier-smtp
* cyrus-imap
* directadmin
* domino-smtp
* dovecot
* dropbear
* drupal-auth
* ejabberd-auth
* exim
* exim-spam
* freeswitch
* froxlor-auth
* gitlab
* grafana
* groupoffice
* gssftpd
* guacamole
* haproxy-http-auth
* horde
* kerio
* lighttpd-auth
* mongodb-auth
* monit
* murmur
* mysql-auth
  * To log wrong MySQL access attempts add to `/etc/mysql/my.cnf` in
    `[mysqld]` or equivalent section: `log-warning = 2`
* nagios
* named-refused
* nginx-http-auth
* nginx-limit-req
  * To use 'nginx-limit-req' jail you should have `ngx_http_limit_req_module`
    and define `limit_req` and `limit_req_zone` as described in nginx
    documentation
    <http://nginx.org/en/docs/http/ngx_http_limit_req_module.html>
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
* phpmyadmin-syslog
* portsentry
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
* screensharing
* selinux-ssh
* sendmail-auth
* sendmail-reject
* sieve
* slapd
* softethervpn
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
* traefik-auth
* uwimap-auth
* vsftpd
* webmin-auth
* wuftpd
* xinetd-fail
  * This pre-defined jail does not specify ports to ban since this service can
    run on many choices of ports. By default this means that all ports will be
    blocked for IPs that are banned by this jail. You may want to override the
    hash to add in specific ports in the `port` parameter.
* znc-adminlog
* zoneminder

### Defining filters ###

You might want to define new filters for your new jails. To do that, you can
use the `fail2ban::filter` defined type:

~~~puppet
fail2ban::filter { 'jenkins':
  failregexes => [
    # Those regexes are really arbitrary examples.
    'Invalid login to Jenkins by user mooh by IP \'<HOST>\'',
    'Forced entry trial by <HOST>',
  ],
}
~~~

### Defining actions ###

Fail2ban can do pretty much what you want it to do (e.g. run an action) when an
IP matches a filter enough times during the rate limit set by the jail.

To define a new action, you can use the `fail2ban::action` defined type.
Here's an example that would call out to a fictitious REST API whenever an IP
address is banned and unbanned:

~~~puppet
fail2ban::action { 'rest_api':
  ensure      => present,
  actionban   => ['curl -s -X PUT http://yourapi:8080/theapi/v4/firewall/rules -H "Content-Type:application/json" -H "Authorization: ..." -d "{\"ban\": \"<ip>\"}"'],
  actionunban => ['curl -s -X DELETE http://yourapi:8080/theapi/v4/firewall/rules/1 -H "Authorization: ..."'],
}
~~~

#### Python action scripts ####

Fail2ban lets users define actions as python scripts. These actions should
exist as a file within `/etc/fail2ban/action/$action.py` where `$action` is the
name of the action.

The contents of those files can differ wildly. Other than ensuring the
location of the file and its permissions, this module wouldn't actually add
much more on top of simply managing the python scripts as `file` resources, so
no defined resource type was created for them.

If you manage such an action script, it is recommended to make it signal
`Class['fail2ban::service']` (e.g.  with `~>`) in order to automatically
restart the service upon changes.

#### nftables support ####

Fail2ban supports nftables with the builtin actions:

* `nftables`
* `nftables-multiport` (it's just an alias of `nftables`)
* `nftables-allports`

These actions use nftables' `set` functionality to contain banned IPs instead
of adding a firewall rule for each new banned IP. This should make your
firewall more efficient if you have lots of banned IPs.

Since nftables is now used by default on Debian since the buster release but
`iptables` is still used by fail2ban's default action, here's how to quickly
enable usage of nftables for fail2ban:

Only two global parameters need to be changed:

* `chain` needs to be set to the same value but lowercased
  * by default the chain used is expected to be in table `filter` of address
    family `ip` (e.g. the iptables compatibility table).
* `banaction` needs to be set to the nftables action of your choice
* If you want to customize further what table, address family, chain hook, hook
  priority or the action taken by the rule if an address is matched, you can
  create a file `/etc/fail2ban/filter.d/nftables-common.local` that overrides
  the variables in the Init section of the `nftables.conf` file.

Here's an example minimal configuration for using nftables with one sshd jail
defined as usual:

~~~puppet
class { 'fail2ban':
  banaction      => 'nftables',
  chain          => 'input',
}
$ssh_params = lookup('fail2ban::jail::sshd')
fail2ban::jail { 'sshd':
  * => $ssh_params,
}
~~~

Do note that upon service restart, fail2ban will not create the ip set and the
corresponding rule right away so it will appear as though "it's not working".
They will only be added whenever the first "action" is taken (so when banning
the first IP for a jail). After that you should see both the set and the rule
for that jail when running `nft list ruleset`.

To list which IPs are currently banned, you can either use `fail2ban-client
status sshd` or list elements of the corresponding set. For the example above:
`nft list set filter f2b-sshd`

## Requirements ##

This module depends on the following modules to function:

* puppetlabs' stdlib module (at least version 4.6.0)

## Compatibility ##

This module supports

* Debian 10, 11
* Ubuntu 18.04, 20.04, 22.04
* RHEL 7, 8, 9
* CentOS 7 and 8
  * version 8 is currently EOL and support for it will be removed along with
    version 7 when that one becomes EOL as well

Puppet versions 6 and 7 are supported.

If you still need to use this module with puppet 5 or 4.10+ you can either try
your luck with version 4.x of this module even though support is not official,
or you can use the 3.x releases of the module.

## Upgrade notices ##

* 4.0.0: Support for Debian 11 was added, but Debian 8 was removed from
  supported releases.

  With the removal of debian 8 support, the `$persistent_bans` parameter was
  removed since it is not needed anymore. This has the side-effect of stopping
  management of the `actions.d/iptables-multiport.conf` file, so users may let
  their package manager change it back to its default form now.

  A couple of new parameters have been added to match newly available
  configuration options in the fail2ban version (0.11) in Debian bullseye.

  Watch out though, the `$logpath` parameter has changed data type from
  `String` to `Array[String]` so you'll need to adapt your calls to the main
  class and to the `jail` defined type.

  The `$action` parameter in the main class and in the `fail2ban::jail` defined
  type now accept an array of strings. Using a simple `String` is now
  considered deprecated and the data type will get removed in version 5.x of
  the module.

  Similarly, the `$failregex` and `$ignoreregex` parameters in the main class
  now accept an array of strings and using a simple `String` is now considered
  deprecated. The `String` type will be removed from those parameters in
  version `5.x` of the module.

  Some new default jails were added to match what's available in newer
  versions of fail2ban. You can check them out in `data/common.yaml`.

  Some default jails were modified. You might want to check what their changes
  are before upgrading. Namely:

  * asterisk
  * dovecot
  * freeswitch
  * murmur
  * mysql-auth was renamed to mysqld-auth
  * nrpe was renamed to nagios
  * nsd
  * openhab-auth
  * openwebmail

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

This module uses puppet-strings comments. The most stable way of using
puppet-strings is to reuse the same version as what's specified in the Gemfile,
so start by running `gem install` (you might need to setup local path for
non-root install first).

Then you can generate HTML documentation in the `docs` directory with the
following command:

~~~bash
bundle exec rake strings:generate
~~~

The `REFERENCE.md` file should be updated along with the code if any API and
accompanying puppet-strings documentation change. You can do this with:

~~~bash
bundle exec rake strings:generate:reference
~~~

## Testing ##

This module has some tests that you can run to ensure that everything is
working as expected.

Before you can use the tests, make sure that you setup your local environment
with `bundle install`.

### Smoke tests ###

You can run sanity check with the `validate` task from puppet-syntax:

~~~bash
bundle exec rake validate
~~~

This will check manifest syntax, template syntax, yaml syntax for hiera files
and ensure that the REFERENCE.md file is up to date.

Additionally to this, you can also use rubocop to run sanity checks on ruby
files:

~~~bash
bundle exec rake rubocop
~~~

### Unit tests ###

The unit tests are built with rspec-puppet.

The usual rspec-puppet_helper rake tasks are available. So, to run spec tests:

~~~bash
bundle exec rake spec
~~~

### Funtionality tests ###

Unit tests are great, but sometimes it's nice to actually run the code in order
to see if everything is setup properly and that the software is working as
expected.

This repository does not have automated functionality tests, but it has a
`Vagrantfile` that you can use to bring up a VM and run this module inside it.

The `Vagrantfile` expects you to have the vagrant plugin
`vagrant-librarian-puppet` installed. If you don't have it you can also
download this module's requirements (see `metadata.json`) and place them inside
`tests/modules/`.

A couple of manifest files inside `tests/` prepare sets of use cases. You can
modify the `Vagrantfile` to use any of them for provisioning the VM.
