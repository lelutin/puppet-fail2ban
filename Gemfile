source 'https://rubygems.org'

gem 'rake'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'].to_s : ['>= 6.0']
gem 'puppet', puppetversion

group :tests do
  # This draws in rubocop and other useful gems for puppet tests
  gem 'voxpupuli-test', '~> 13.2.0'
  # Brings metadata2gha for CI
  gem 'puppet_metadata', '< 7.0'
end

group :docs do
  gem 'puppet-strings', '< 6.0.0'
end
