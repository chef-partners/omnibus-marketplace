include_recipe 'chef-marketplace::config'

role = node['chef-marketplace']['role'] # 'server' or 'analytics'
platform = node['chef-marketplace']['platform'] # 'aws' or 'azure' etc.

# Base recipes
include_recipe "chef-marketplace::_#{role}_enable"
include_recipe "chef-marketplace::_#{platform}_#{role}_enable"

# Publishing recipes
if node['chef-marketplace']['publishing']['enabled']
  include_recipe 'chef-marketplace::_security'
  include_recipe "chef-marketplace::#{platform}_security"
end
