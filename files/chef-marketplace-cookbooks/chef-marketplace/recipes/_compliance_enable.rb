directory '/etc/chef-compliance' do
  owner 'root'
  group 'root'
  action :create
end

template '/etc/chef-compliance/chef-compliance.rb' do
  source 'chef-compliance.rb.erb'
  owner 'root'
  group 'root'
  action :create
end

file '/etc/sudoers.d/chef-compliance' do
  source 'chef-compliance-sudoers'
  owner 'root'
  group 'root'
  mode 0440
  action :create
end
