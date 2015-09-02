include_recipe 'chef-marketplace::config'

role = node['chef-marketplace']['role'] # 'server', 'analytics', 'aio'

include_recice "chef-marketplace::_#{role}_disable"
