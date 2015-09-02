include_recipe 'chef-marketplace::_server_enable'
include_recipe 'chef-marketplace::_analytics_enable'

template '/etc/opscode-analytics/opscode-analytics.rb' do
  source 'opscode-analytics.rb.erb'
  variables(
    topology: 'combined',
    analytics_fqdn: node['fqdn'],
    ssl_port: node['chef-marketplace']['analytics']['ssl_port'].to_i

  )

  action :create
end
