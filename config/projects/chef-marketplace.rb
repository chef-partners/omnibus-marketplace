name "chef-marketplace"
maintainer "Chef Software, Inc. <partnereng@chef.io>"
homepage "http://www.chef.io"
license "Apache-2.0"
license_file "LICENSE"

install_dir "/opt/chef-marketplace"
build_version Omnibus::BuildVersion.semver
build_iteration 1

# NOTE: If you update ruby's minor version make sure you update the gem install
#       paths in the other software definitions.
override :ruby, version: "2.4.2"

# Pin to 13.6.0 until master gets more stable
override :'chef-gem', version: "13.6.0"

dependency "preparation"
dependency "postgresql92" # only the client
dependency "sequel-gem"
dependency "pg-gem"
dependency "server-plugin-cookbooks"
dependency "reckoner"
dependency "biscotti"
dependency "chef-gem"
dependency "cheffish-gem"
dependency "chef-marketplace-ctl"
dependency "chef-marketplace-gem"
dependency "chef-marketplace-cookbooks"
dependency "version-manifest"

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV["OMNIBUS_RPM_SIGNING_PASSPHRASE"]
end
