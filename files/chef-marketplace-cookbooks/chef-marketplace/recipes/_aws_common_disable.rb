file '/etc/chef/ohai/hints/ec2.json' do
  action :delete
end

user 'ec2-user' do
  action :delete
end

package 'cloud-init' do
  action :uninstall
end

template '/etc/cloud/cloud.cfg' do
  action :delete
end
