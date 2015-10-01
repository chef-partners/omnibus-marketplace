include_recipe 'chef-marketplace::config'

unless mirrors_reachable?
  Chef::Log.warn 'Skipping package upgrade because mirrors are not available or outboud traffic is disabled...'
  return
end

chef_ingredient 'chef-marketplace' do
  action :upgrade
  notifies :run, 'execute[chef-marketplace-ctl reconfigure]'
end

execute 'chef-marketplace-ctl reconfigure' do
  action :nothing
end
