# Puppet module for fail2ban #

Install and manage fail2ban with puppet

To use this module just include the jail2ban class. To change default
configurations in /etc/fail2ban/jail.conf, you can pass values to parameters to
the fail2ban class. See section below for full list of parameters.

Here's an example that sets default ignored IP address to local host and
another non-routed IP:

~~~
class { 'fail2ban':
  ignoreip => '127.0.0.1 10.0.0.1',
}
~~~

You can create a jail with the fail2ban::jail defined type (see section below)
or you can use one of the predefined fail2ban::jail::* classes.

You can also create a filter for use with jails with the fail2ban::filter
defined type (see section below).

## Requirements ##

This module depends on the following modules to function:

 * puppetlabs' stdlib module (at least version 3.0.0)
 * puppetlabs' concat module (at least version 1.0.0)

## Compatibility ##

This module supports

 * Debian 7 and 8
 * RHEL 6 and 7
 * CentOs 6 and 7

Please note that a bug in puppet 3.x with regards to package dependencies will
make it print warnings about missing dependencies. This issue was fixed in
puppet 4.0.0. Unfortunately, since puppet 3.x is currently getting security
patches only, there is no plan to backport the fix.

For more details, see : https://tickets.puppetlabs.com/browse/PUP-3121

## Upgrade notices ##

 * `ensure` parameter deprecated in fail2ban::jail since 1.2.0. Will be removed
     for 2.x.  Since the jail define uses puppetlabs-concat to define a
     fragment for each jail to be concatenated in `/etc/fail2ban/jail.local`,
     we're purposefully avoiding to use the ensure parameter. This is because
     the 2.x branch of puppetlabs-concat has deprecated this parameter and
     issues warnings to users that are using it. Users of the fail2ban module
     should instead remove the resources for the jails that must be removed.

 * The directory `/etc/fail2ban/jail.d` is now getting purged by default. Users
     who would like to preserve files in this directory that are not managed by
     puppet should now set the `purge_jail_dot_d` parameter to the `fail2ban`
     class to false.
     
## Parameters for fail2ban.local ##

All these values are used to override fail2ban.conf defaults by adding values
to fail2ban.local file.

* `loglevel` Sets the verbosity of the logging. 
   Default: INFO [CRITICAL | ERROR | WARNING | NOTICE | INFO | DEBUG]
* `logtarget` Set the log target. This could be a file, SYSLOG, STDERR or STDOUT.
   Only one log target can be specified. If you change logtarget from the default
   value and you are using logrotate -- also adjust or disable rotation in the
   corresponding configuration file. Default: STDERR [ STDOUT | STDERR | SYSLOG | FILE ]
* `syslogsocket` Set the syslog socket file. Only used when logtarget is SYSLOG
   auto uses platform.system() to determine predefined paths. Default: auto [ auto | FILE ]
* `socket` Set the socket file. This is used to communicate with the daemon. Do
   not remove this file when Fail2ban runs. It will not be possible to communicate 
   with the server afterwards. Default: /var/run/fail2ban/fail2ban.sock
* `pidfile` Set the PID file. This is used to store the process ID of the fail2ban server.
   Default: /var/run/fail2ban/fail2ban.pid
* `dbfile` Set the file for the fail2ban persistent data to be stored.
   A value of ":memory:" means database is only stored in memory and data is lost 
   when fail2ban is stopped. A value of "None" disables the database.
   Default: /var/lib/fail2ban/fail2ban.sqlite3 [ None | :memory: | FILE ]
* `dbpurgeage` Sets age at which bans should be purged from the database.
   Default: 86400 (24hours) [ SECONDS ]

## Parameters to fail2ban class ##

All of the values configured through the `fail2ban` class are used to configure
global default values. These values can be overridden by individual jails.

 * `ignoreip` Default ignored IP(s) when parsing logs. Default value is
   '127.0.0.1'. Multiple values should be separated by spaces
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
 * `purge_jail_dot_d` Boolean value that decides whether
   `/etc/fail2ban/jail.d/` is purged of files that are not managed by puppet.
   Default value is true.

## Defining jails ##

To define a jail, you can use one of the predefined jails (see list below). Or
you can define your own with the fail2ban::jail defined type:

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
 * `logpath` Path of the log to monitor. This parameter is mandatory.
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
 * `ignoreip` Override default IP(s) to ignore (e.g. don't ban this IP).
 * `order` Optional numerical position. This lets you order jails as you see
   fit.
 * `backend` Override default log file following method.

To remove a jail, simply remove the resource for it from your manifests:
puppetlabs-concat will automatically remove all fragments that are not managed
with a concat::fragment resource (which the fail2ban::jail define uses).

### Predefined jails ###

 * apache_noscript
 * apache_overflows
 * apache
 * asterisk
 * courierauth
 * couriersmtp
 * dovecot
 * dropbear
 * named_refused_tcp
 * pam_generic
 * postfix
 * proftpd
 * pure_ftpd
 * sasl
 * sendmailauth
 * sendmailreject
 * ssh_ddos
 * ssh
 * vsftpd
 * wuftpd
 * xinetd_fail

## Defining filters ##

You might want to define new filters for your new jails. To do that, you can
use the fail2ban::filter defined type:

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

