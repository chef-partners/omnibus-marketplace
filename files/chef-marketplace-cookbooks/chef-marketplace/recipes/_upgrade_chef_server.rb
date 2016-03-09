bash 'chef-server-ctl reconfigure' do
  code 'chef-server-ctl reconfigure'
  action :nothing
end

bash 'chef-server-ctl upgrade' do
  code 'chef-server-ctl upgrade'
  action :nothing
end

bash 'chef-server-ctl restart' do
  code 'chef-server-ctl restart'
  action :nothing
end

bash 'chef-server-ctl start' do
  code 'chef-server-ctl start'
  action :nothing
end

bash 'opscode-reporting-ctl reconfigure' do
  code 'opscode-reporting-ctl reconfigure'
  action :nothing
end

bash 'chef-manage-ctl reconfigure' do
  code 'chef-manage-ctl reconfigure'
  action :nothing
end

bash 'chef-manage-ctl restart' do
  code 'chef-manage-ctl restart'
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
