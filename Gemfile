source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'].to_s : ['>= 6.0']

gem 'facter', '>= 2.4.0'
gem 'puppet', puppetversion
gem 'rake'

group :tests do
  gem 'puppetlabs_spec_helper'
  # Brings metadata2gha for our CI
  gem 'puppet_metadata', '< 7.0'
  # This draws in rubocop and other useful gems for puppet tests
  gem 'voxpupuli-test', '~> 13.2.0'
end

group :docs do
  gem 'puppet-strings', '< 6.0.0'
end
