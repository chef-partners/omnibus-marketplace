name 'chef-marketplace'
maintainer 'Chef Software, Inc. <partnereng@chef.io>'
homepage 'http://www.chef.io'

install_dir '/opt/chef-marketplace'
build_version Omnibus::BuildVersion.semver
build_iteration 1

# creates required build directories
dependency 'preparation'

dependency 'chef-marketplace'
dependency 'chef-marketplace-cookbooks'

# version manifest file
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
end
