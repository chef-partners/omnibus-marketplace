include_recipe 'chef-marketplace::enable'

file '/etc/chef-marketplace/chef-marketplace-running.json' do
  content lazy { Chef::JSONCompat.to_json_pretty('chef-marketplace' => node['chef-marketplace']) }
  owner 'root'
  group 'root'
  mode '0600'
end
