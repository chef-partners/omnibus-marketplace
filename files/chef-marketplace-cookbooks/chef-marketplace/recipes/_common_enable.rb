motd '50-chef-marketplace-appliance' do
  source 'motd.erb'
  cookbook 'chef-marketplace'
  variables(
    role: node['chef-marketplace']['role'],
    manage_url: manage_url,
    analytics_url: node['chef-marketplace']['role'] == 'aio' ? analytics_url : false,
    support_email: node['chef-marketplace']['support']['email'],
    doc_url: node['chef-marketplace']['documentation']['url']
  )
  action motd_action
end

directory '/etc/chef/ohai/hints' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

file "etc/chef/ohai/hints/#{node['chef-marketplace']['platform']}.json" do
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
    gecos: gecos
  )
  action :create
end
