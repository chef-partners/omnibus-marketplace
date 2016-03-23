chef_ingredient "compliance" do
  action :upgrade
  notifies :run, "bash[chef-compliance-ctl reconfigure]", :immediately if compliance_configured?
end

bash "chef-compliance-ctl reconfigure" do
  code "chef-compliance-ctl reconfigure"
  action :nothing
end
