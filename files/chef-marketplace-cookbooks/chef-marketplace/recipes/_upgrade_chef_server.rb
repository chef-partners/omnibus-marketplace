bash 'chef-server-ctl reconfigure' do
  action :nothing
end

bash 'chef-server-ctl upgrade' do
  action :nothing
end

bash 'chef-server-ctl restart' do
  action :nothing
end

bash 'chef-server-ctl start' do
  action :nothing
end

bash 'opscode-reporting-ctl reconfigure' do
  action :nothing
end

bash 'chef-manage-ctl reconfigure' do
  action :nothing
end

bash 'chef-manage-ctl restart' do
  action :nothing
end

chef_ingredient 'chef-server' do
  action :upgrade

  if chef_server_configured?
    notifies :run, 'bash[chef-server-ctl reconfigure]', :immediately
    notifies :run, 'bash[chef-server-ctl upgrade]', :immediately
    notifies :run, 'bash[chef-server-ctl restart]', :immediately
  end
end

chef_ingredient 'manage' do
  action :upgrade

  if chef_server_configured?
    notifies :run, 'bash[chef-server-ctl start]', :immediately
    notifies :run, 'bash[chef-manage-ctl reconfigure]', :immediately
    notifies :run, 'bash[chef-manage-ctl restart]', :immediately
    notifies :run, 'bash[chef-server-ctl restart]'
  end
end

chef_ingredient 'reporting' do
  action :upgrade

  if chef_server_configured?
    notifies :run, 'bash[chef-server-ctl start]', :immediately
    notifies :run, 'bash[opscode-reporting-ctl reconfigure]', :immediately
    notifies :run, 'bash[chef-server-ctl restart]'
  end
end
