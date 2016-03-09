# Chef Marketplace Changelog

# 0.0.8 (2016-03-09)
## chef-marketplace-cookbooks
* Live stream during publishing

## chef-marketplace-ctl
* Fix node registration when run by a non-root user

# 0.0.7 (2016-03-08)
## omnibus-marketplace
* Add Biscotti cookie signing daemon for initial marketplace authorization

## chef-marketplace-cookbooks
* Update cookbooks to use the bash resource instead of execute
* Update cookbooks to please Azure security requirements
* Update cookbooks to configure Manage with new setup and support info
* Update Chef Server plugin config
* Restructured initial cookbook configuration
* Fix issue where Chef Server plugin config was overwriting oc_id config [:heart: Nell](https://github.com/orgs/chef/people/nellshamrell)
* Fix issue where FQDN was not properly configured when Ohai cloud_v2 would return empty strings [:heart: Jeremiah](https://github.com/orgs/chef/people/jeremiahsnapp)

# 0.0.6 (2016-02-09)
## omnibus-marketplace
* Please Rubocop

## chef-marketplace-gem
* Update AWS SDK marketplace metering API specification
* Update Reckoner usage dimensions for AIO and Compliance types
* Automatically detect AWS Region for Ec2 usage updater

## chef-marketplace-cookbooks
* Update license config options for marketplace.rb
* Update cookbooks for Ubuntu 14.04 support
* Update cookbooks for Azure support

# 0.0.5 (2016-01-15)
## omnibus-marketplace
* Update README.md
* Use cloud-init to configure instances at boot time
* 'preconfigure' marketplace images to make setup times shorter
* Add reckoner billing daemon and support for Flexible Consumption

## chef-marketplace-ctl
* Add chef-marketplace-ctl register-node command
* Add --preconfigure switch to chef-marketplace-ctl setup
* Use standard omnibus-ctl to get service commands
* Add chef-marketplace-ctl prepare-for-publishing command

## chef-marketplace-gem
* Add Marketplace Api client
* Add Node registration to setup
* Update setup to support preconfiguring
* Add initial reckoner support

## chef-marketplace-cookbooks
* Add node registration recipe
* Add marketplace_api config context to marketplace.rb
* Add preconfigure recipes
* Add reckoner and runit recipes
* Restructure common, security, and publishing recipes for the new publish command

# 0.0.4 (2015-11-09)
## omnibus-marketplace
* Add shim server-plugin cookbooks to please the Chef Server plugin design

## chef-marketplace-cookbooks
* Remove converging chef-marketplace cookbooks during chef-server-ctl reconfigure

# 0.0.3 (2015-11-03)
## omnibus-marketplace
* Add chef-marketplace-gem
* Add initial support for RHEL, Oracle, and Ubuntu 14.04
* Update Ruby to 2.2.3
* Update Rubygems to 2.4.8
* Update Chef gem to use master

## chef-marketplace-gem
* Add initial Chef Compliance support

## chef-marketplace-ctl
* Add chef-compliance to upgrade command
* Refactor upgrade command to use a single chef run
* Dynamically link ctl commands depending on configured role

## chef-marketplace-cookbooks
* Refactor upgrade recipe

# 0.0.2 (2015-09-09)
## omnibus-marketplace
* Add CHANGELOG.md
* Update README.md
* Remove 'chef-marketplace' software definition
* Add sequel gem
* Add postgresql client

## chef-marketplace-ctl
* Add chef-marketplace-ctl hostname command
* Add chef-marketplace-ctl trim-actions-db command
* Update setup UI to be colorized
* Update upgrade command tests
* Update several command descriptions
* Update the upgrade command to verify that package mirrors are reachable
* Use socketless chef-zero to avoid port collisions
* Bug fixes

## chef-marketplace-cookbooks
* Add All-In-One mode support
* Refactor chef-marketplace to use the new Chef Server plugin registration
* Update chef-ingredient cookbook
* Add 'api_fqdn', 'license_count', 'security' and 'analytics' options to
  marketplace.rb config
* Move FQDN detection from setup command into the marketplace cookbook
* Refactor recipe structure
* Bug fixes

# 0.0.1 (2015-08-10)
## omnibus-marketplace
* Add initial project and software definitions
* Add LICENSE
* Update README.md

## chef-marketplace-ctl
* Add chef-marketplace-ctl upgrade command
* Add chef-marketplace-ctl test command
* Add chef-marketplace-ctl setup command
* Add rake task for running tests and linting
* Add unit and functional tests for commands
* Bug fixes

## chef-marketplace-cookbooks
* Port marketplace_image cookbook chef-marketplace
* Add `disable_outbound_traffic` config option
* Add OpenStack plaform support
* Manage /etc/hosts via cloud-init
* Add automatic reporting database pruning
* Bug fixes
