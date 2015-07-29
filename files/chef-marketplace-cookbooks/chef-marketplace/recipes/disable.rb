include_recipe 'chef-marketplace::config'

role = node['chef-marketplace']['role'] # 'server' or 'analytics'
platform = node['chef-marketplace']['platform'] # 'aws' or 'azure' etc.

include_recice "chef-marketplace::_#{role}_disable"
include_recipe "chef-marketplace::_#{platform}_#{role}_disable"
