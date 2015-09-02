include_recipe 'chef-marketplace::config'
include_recipe 'chef-marketplace::_register_plugin'

role = node['chef-marketplace']['role'] # 'server', 'analytics', 'aio'

# Base recipes
include_recipe "chef-marketplace::_#{role}_enable"

# Publishing/Security
include_recipe 'chef-marketplace::_security' if security_enabled?
