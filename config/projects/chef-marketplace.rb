name 'chef-marketplace'
maintainer 'Chef Software, Inc. <partnereng@chef.io>'
homepage 'http://www.chef.io'

install_dir '/opt/chef-marketplace'
build_version Omnibus::BuildVersion.semver
build_iteration 1

override :ruby, version: '2.2.4'
override :chef, version: 'master'
override :berkshelf, version: 'v4.2.3'

dependency 'preparation'
dependency 'postgresql92' # only the client
dependency 'sequel-gem'
dependency 'pg-gem'
dependency 'server-plugin-cookbooks'
dependency 'reckoner'
dependency 'biscotti'
dependency 'chef-marketplace-ctl'
dependency 'chef-marketplace-gem'
dependency 'chef-marketplace-cookbooks'
dependency 'chef'
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
end
