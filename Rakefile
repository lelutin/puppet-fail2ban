require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'

# Temporary workaround: the keys we use in hiera for default jail data sets
# tend to trigger errors from puppet-syntax. Fixing that is going to be
# annoying.
PuppetSyntax.check_hiera_keys = false
