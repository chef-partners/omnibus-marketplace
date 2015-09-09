motd '50-chef-marketplace-appliance' do
  source 'motd.erb'
  cookbook 'chef-marketplace'
  variables motd_variables
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

case node['platform']
when 'oracle'
  remote_file "/tmp/epel-release-7-5.noarch.rpm" do
    source "ftp://ftp.muug.mb.ca/mirror/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm"
    owner "root"
    group "root"
    mode "0644"
    action :create
  end

  remote_file "/tmp/python-pygments-1.4-9.el7.noarch.rpm" do
    source "ftp://ftp.muug.mb.ca/mirror/centos/7.1.1503/os/x86_64/Packages/python-pygments-1.4-9.el7.noarch.rpm"
    owner "root"
    group "root"
    mode "0644"
    action :create
  end

  package "epel-release-7-5" do
    action :install
    source "/tmp/epel-release-7-5.noarch.rpm"
    provider Chef::Provider::Package::Rpm
  end

  package "python-imaging" do
    action :install
  end

  package "python-pygments" do
    action :install
    source "/tmp/python-pygments-1.4-9.el7.noarch.rpm"
    provider Chef::Provider::Package::Rpm
  end
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

package 'cronie' do
  action :install
  only_if do
    (node['chef-marketplace']['reporting']['cron']['enabled'] ||
     node['chef-marketplace']['actions']['trimmer']['enabled']
    ) && mirrors_reachable?
  end
end
