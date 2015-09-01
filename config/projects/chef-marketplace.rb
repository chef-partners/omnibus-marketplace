name 'chef-marketplace'
maintainer 'Chef Software, Inc. <partnereng@chef.io>'
homepage 'http://www.chef.io'

install_dir '/opt/chef-marketplace'
build_version Omnibus::BuildVersion.semver
build_iteration 1

override :cacerts, version: '2014.08.20'
override :ruby, version: '2.1.6'
override :'chef-gem', version: '12.4.1'
# These default to ancient versions in omnibus-software
override :rubygems, version: '2.4.5'
override :bundler, version: '1.10.6'

dependency 'preparation'
dependency 'chef-gem'
dependency 'chef-marketplace-ctl'
dependency 'chef-marketplace-cookbooks'
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
end
