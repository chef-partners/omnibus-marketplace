log 'Upgrading the Chef Server..'

include_recipe 'yum-centos::default'

chef_ingredient 'chef-server' do
  action :upgrade
  notifies :run, "execute['chef-server-ctl upgrade']", :immediately
end

execute 'chef-server-ctl upgrade' do
  action :nothing
end

chef_ingredient 'manage' do
  action :upgrade
  notifies :run, "execute['opscode-manage-ctl reconfigure']", :immediately
end

execute 'opscode-manage-ctl reconfigure' do
  action :nothing
end

chef_ingredient 'reporting' do
  action :upgrade
  notifies :run, "execute['opscode-reporting-ctl reconfigure']", :immediately
end

execute 'opscode-reporting-ctl reconfigure' do
  action :nothing
end

log 'Upgrade complete!'
