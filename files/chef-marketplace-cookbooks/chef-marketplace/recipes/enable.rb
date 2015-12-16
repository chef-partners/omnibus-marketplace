include_recipe 'chef-marketplace::config'
include_recipe 'chef-marketplace::_register_plugin'

# 'server', 'analytics', 'aio', 'compliance'
role = node['chef-marketplace']['role']

# Base recipes
include_recipe "chef-marketplace::_#{role}_enable"

# Setup omnibus commands
include_recipe 'chef-marketplace::_omnibus_commands'

# Initial setup time on Marketplace instances can take a while, especially on
# AIO and Server topologies, because we have to reconfigure 4 to 5 omnibus
# packages.  The preconfigure step is designed to reconfigure all of those
# packages and remove default state, secrets, and sentinels so that the initial
# setup chef-client runs noop as many resources as they can.
include_recipe "chef-marketplace::_#{role}_preconfigure" if currently_publishing?
include_recipe 'chef-marketplace::_security' if security_enabled?
