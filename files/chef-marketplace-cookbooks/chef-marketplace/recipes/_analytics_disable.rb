include_recipe 'chef-marketplace::_common_disable'

file '/etc/cron.d/analytics-database-cleanup' do
  action :delete
end
