execute 'chef-server-ctl reconfigure' do
  action :nothing
end

execute 'chef-server-ctl upgrade' do
  action :nothing
end

execute 'chef-server-ctl restart' do
  action :nothing
end

execute 'chef-server-ctl start' do
  action :nothing
end

execute 'opscode-reporting-ctl reconfigure' do
  action :nothing
end

execute 'chef-manage-ctl reconfigure' do
  action :nothing
end

execute 'chef-manage-ctl restart' do
  action :nothing
end

chef_ingredient 'chef-server' do
  action :upgrade

  if chef_server_configured?
    notifies :run, 'execute[chef-server-ctl reconfigure]', :immediately
    notifies :run, 'execute[chef-server-ctl upgrade]', :immediately
    notifies :run, 'execute[chef-server-ctl restart]', :immediately
  end
end

chef_ingredient 'manage' do
  action :upgrade

  if chef_server_configured?
    notifies :run, 'execute[chef-server-ctl start]', :immediately
    notifies :run, 'execute[chef-manage-ctl reconfigure]', :immediately
    notifies :run, 'execute[chef-manage-ctl restart]', :immediately
    notifies :run, 'execute[chef-server-ctl restart]'
  end
end

chef_ingredient 'reporting' do
  action :upgrade

  if chef_server_configured?
    notifies :run, 'execute[chef-server-ctl start]', :immediately
    notifies :run, 'execute[opscode-reporting-ctl reconfigure]', :immediately
    notifies :run, 'execute[chef-server-ctl restart]'
  end
end
