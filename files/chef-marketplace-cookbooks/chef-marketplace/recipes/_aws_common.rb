directory '/etc/chef/ohai/hints' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

file '/etc/chef/ohai/hints/ec2.json' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

user 'ec2-user' do
  home '/home/ec2-user'
  shell '/bin/bash'
  action [:create, :lock]
end

package 'cloud-init' do
  action :install
end

template '/etc/cloud/cloud.cfg' do
  source 'ec2-cloud-init.erb'
  cookbook 'chef-marketplace'
  action :create
end
