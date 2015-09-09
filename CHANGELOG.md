# Chef Marketplace Changelog

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
