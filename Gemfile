source 'https://rubygems.org'

# Install omnibus software
gem 'omnibus-software', github: 'opscode/omnibus-software'
gem 'omnibus', github: 'opscode/omnibus'
gem 'omnibus-ctl', github: 'chef/omnibus-ctl'
gem 'chef'
gem 'pry'
gem 'rubocop'
gem 'rspec'

group :development do
  # Use Berkshelf for resolving cookbook dependencies
  gem 'berkshelf', '~> 3.1'

  # Use Test Kitchen with Vagrant for converging the build environment
  gem 'test-kitchen',    '~> 1.3'
  gem 'kitchen-vagrant', '~> 0.14'
end
