include_recipe 'chef-marketplace::config'

role = node['chef-marketplace']['role'] # 'server' or 'analytics'

# Base recipes
include_recipe "chef-marketplace::_#{role}_enable"

# Publishing recipes
if node['chef-marketplace']['publishing']['enabled']
  include_recipe 'chef-marketplace::_security'
end
