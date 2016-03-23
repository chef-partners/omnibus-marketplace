chef_ingredient "chef-marketplace" do
  action :upgrade
  notifies :run, "bash[chef-marketplace-ctl reconfigure]"
end

bash "chef-marketplace-ctl reconfigure" do
  code "chef-marketplace-ctl reconfigure"
  action :nothing
end
