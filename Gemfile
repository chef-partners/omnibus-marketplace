source "https://rubygems.org"

# Install omnibus software
gem "omnibus-software", github: "opscode/omnibus-software"
gem "omnibus", github: "opscode/omnibus"
gem "artifactory"
gem "omnibus-ctl", github: "chef/omnibus-ctl"
gem "chef"
gem "pry"
gem "rubocop"
gem "rspec"
gem "rake"
gem "berkshelf"
gem "chefstyle"

# Reckoner Deps
gem "sequel"
gem "aws-sdk", "~> 2"

group :development do
  # Use Test Kitchen with Vagrant for converging the build environment
  gem "test-kitchen"
  gem "kitchen-vagrant"
  gem "kitchen-ec2"
end
