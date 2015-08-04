include_recipe 'chef-marketplace::config'
include_recipe 'yum-centos::default'

publishing = node['chef-marketplace']['publishing']['enabled']

chef_ingredient 'chef-server' do
  action :upgrade
  notifies :run, 'execute[chef-server-ctl upgrade]', :immediately unless publishing
end

execute 'chef-server-ctl upgrade' do
  action :nothing
end

chef_ingredient 'manage' do
  action :upgrade
  notifies :run, 'execute[opscode-manage-ctl reconfigure]', :immediately unless publishing
end

execute 'opscode-manage-ctl reconfigure' do
  action :nothing
end

chef_ingredient 'reporting' do
  action :upgrade
  notifies :run, 'execute[opscode-reporting-ctl reconfigure]', :immediately unless publishing
end

execute 'opscode-reporting-ctl reconfigure' do
  action :nothing
end
