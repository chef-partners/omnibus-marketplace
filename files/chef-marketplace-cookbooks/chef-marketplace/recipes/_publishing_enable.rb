case node['platform']
when 'oracle'
  include_recipe 'chef-marketplace::_oracle_common_enable'
end

directory '/etc/chef/ohai/hints' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

file "/etc/chef/ohai/hints/#{node['chef-marketplace']['platform']}.json" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

user node['chef-marketplace']['user'] do
  home "/home/#{node['chef-marketplace']['user']}"
  shell '/bin/bash'
  action [:create, :lock]
end

package 'cloud-init' do
  action :install
  only_if { mirrors_reachable? }
end

directory '/var/lib/cloud/scripts/per-instance' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Kick off the reconfigures with cloud-init so setup takes less time
template '/var/lib/cloud/scripts/per-instance/chef-marketplace-setup' do
  source 'chef-marketplace-cloud-init-setup.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/etc/cloud' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

template '/etc/cloud/cloud.cfg' do
  source 'cloud-init.erb'
  cookbook 'chef-marketplace'
  variables(
    default_user: node['chef-marketplace']['user'],
    gecos: gecos,
    platform: node['chef-marketplace']['platform']
  )
  action :create
end

package cron_package do
  action :install
  only_if do
    (node['chef-marketplace']['reporting']['cron']['enabled'] ||
     node['chef-marketplace']['actions']['trimmer']['enabled']
    ) && mirrors_reachable?
  end
end
