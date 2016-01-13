if flexible_spending_enabled?
  include_recipe 'chef-marketplace::_runit_prepare'

  directory '/var/opt/chef-marketplace/reckoner/etc' do
    owner 'opscode'
    group 'opscode'
    mode '0775'
    recursive true
    action :create
  end

  directory '/var/log/chef-marketplace/reckoner' do
    owner 'root'
    group 'root'
    mode '0775'
    recursive true
    action :create
  end

  template '/var/opt/chef-marketplace/reckoner/etc/reckoner.rb' do
    # TODO: we need to pass 'user' and 'password' db variables for compliance
    source 'reckoner.rb.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'runit_service[reckoner]'
    action :create
  end

  link '/opt/chef-marketplace/embedded/service/reckoner/conf/reckoner.rb' do
    to '/var/opt/chef-marketplace/reckoner/etc/reckoner.rb'
  end

  component_runit_service 'reckoner' do
    package 'chef-marketplace'
  end
else
  runit_service 'reckoner' do
    action :disable
  end
end
