name 'chef-marketplace'
maintainer 'Chef Software, Inc. <partnereng@chef.io>'
homepage 'http://www.chef.io'

install_dir '/opt/chef-marketplace'
build_version Omnibus::BuildVersion.semver
build_iteration 1

override :cacerts, version: '2014.08.20'
override :ruby, version: '2.2.3'
override :chef, version: 'master'
# These default to ancient versions in omnibus-software
override :rubygems, version: '2.4.8'
override :bundler, version: '1.10.7.depsolverfix.0'

dependency 'preparation'
dependency 'postgresql92' # only the client
dependency 'chef-marketplace-ctl'
dependency 'chef-marketplace-gem'
dependency 'chef-marketplace-cookbooks'
dependency 'reckoner'
dependency 'server-plugin-cookbooks'
dependency 'chef'
dependency 'sequel-gem'
dependency 'pg-gem'
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
end
