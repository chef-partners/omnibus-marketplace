include_recipe 'chef-marketplace::config'

unless mirrors_reachable?
  Chef::Log.warn 'Skipping package upgrade because mirrors are not available or outboud traffic is disabled...'
  return
end

include_recipe 'yum-centos::default'

chef_ingredient 'analytics' do
  action :upgrade
  notifies :run, 'execute[opscode-analytics-ctl reconfigure]', :immediately if analytics_configured?
end

execute 'opscode-analytics-ctl reconfigure' do
  action :nothing
end
