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
