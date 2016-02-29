chef_ingredient 'analytics' do
  action :upgrade
  notifies :run, 'bash[opscode-analytics-ctl reconfigure]', :immediately if analytics_configured?
end

bash 'opscode-analytics-ctl reconfigure' do
  action :nothing
end
