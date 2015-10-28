include_recipe 'chef-marketplace::config'
include_recipe 'chef-marketplace::_register_plugin'

# 'server', 'analytics', 'aio', 'compliance'
role = node['chef-marketplace']['role']

# Base recipes
include_recipe "chef-marketplace::_#{role}_enable"

# Setup omnibus commands
include_recipe 'chef-marketplace::_omnibus_commands'

# Publishing/Security
include_recipe 'chef-marketplace::_security' if security_enabled?
