chef_ingredient 'chef-compliance' do
  action :upgrade
  notifies :run, 'execute[chef-compliance-ctl reconfigure]', :immediately if compliance_configured?
end

execute 'chef-compliance-ctl reconfigure' do
  action :nothing
end
