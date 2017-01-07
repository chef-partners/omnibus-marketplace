source "https://rubygems.org"

# Install omnibus software
gem "omnibus-software", github: "opscode/omnibus-software"
gem "omnibus", github: "opscode/omnibus"
gem "omnibus-ctl", github: "chef/omnibus-ctl"
gem "chef"
gem "pry"
gem "rubocop"
gem "rspec"
gem "berkshelf"
gem "chefstyle"
gem "chef-provisioning"
gem "chef-provisioning-aws"
gem "kitchen-ec2"
gem 'rainbow', '>= 2.1.0', '< 2.2.0' # https://github.com/sickill/rainbow/issues/40

gem "nokogiri", "= 1.6.8.1"

# Reckoner Deps
gem "sequel"
gem "aws-sdk"

group :development do
  # Use Test Kitchen with Vagrant for converging the build environment
  gem "test-kitchen"
  gem "kitchen-vagrant"
end
