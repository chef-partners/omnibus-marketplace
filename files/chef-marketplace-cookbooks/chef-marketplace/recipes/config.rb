directory '/etc/chef-marketplace' do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
end

if File.exist?('/etc/chef-marketplace/marketplace.rb')
  Marketplace.from_file('/etc/chef-marketplace/marketplace.rb')
end

node.consume_attributes('chef-marketplace' => Marketplace.save(false))
