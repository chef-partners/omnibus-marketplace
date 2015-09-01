include_recipe 'chef-marketplace::_common_enable'

directory '/etc/opscode-analytics/' do
  owner 'root'
  group 'root'
  action :create
end
