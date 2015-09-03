# Chef Marketplace Changelog

# 0.0.2 (2015-09-03)
## omnibus-marketplace
* Add CHANGELOG.md
* Update README.md
* Remove 'chef-marketplace' software definition

## chef-marketplace-ctl
* Bug fixes
* Use socketless chef-zero to avoid port collisions
* Add chef-marketplace-ctl hostname command
* Update setup UI to be colorized
* Update upgrade command tests tests
* Update command descriptions
* Update the upgrade command to verify that package mirrors are reachable

## chef-marketplace-cookbooks
* Bug fixes
* Add All-In-One mode support
* Refactor chef-marketplace to use the new Chef Server plugin registration
* Update chef-ingredient cookbook
* Add 'api_fqdn', 'license_count', 'security' and 'analytics' options to
  marketplace.rb config
* Move FQDN detection from setup command into the marketplace cookbook
* Refactor recipe structure

# 0.0.1 (2015-08-10)
## omnibus-marketplace
* Add initial project and software definitions
* Add LICENSE
* Update README.md

## chef-marketplace-ctl
* Bug fixes
* Add chef-marketplace-ctl upgrade command
* Add rake task for running tests and linting
* Add unit and functional tests for commands

## chef-marketplace-cookbooks
* Bug fixes
* Port marketplace_image cookbook chef-marketplace
* Add `disable_outbound_traffic` config option
* Add OpenStack plaform support
* Manage /etc/hosts via cloud-init
* Add automatic reporting database pruning
