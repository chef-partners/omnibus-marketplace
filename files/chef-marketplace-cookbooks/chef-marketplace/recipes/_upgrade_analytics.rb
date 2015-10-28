chef_ingredient 'analytics' do
  action :upgrade
  notifies :run, 'execute[opscode-analytics-ctl reconfigure]', :immediately if analytics_configured?
end

execute 'opscode-analytics-ctl reconfigure' do
  action :nothing
end
