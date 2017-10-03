# Possibly run actions
bash "chef-server-ctl reconfigure" do
  code "chef-server-ctl reconfigure"
  only_if { chef_server_configured? }
  action :nothing
end

bash "chef-server-ctl upgrade" do
  code "chef-server-ctl upgrade"
  only_if { chef_server_configured? }
  action :nothing
end

bash "chef-server-ctl start" do
  code "chef-server-ctl start"
  only_if { chef_server_configured? }
  action :nothing
end

# Chef Server
bash "chef-server-ctl stop" do
  code "chef-server-ctl stop"
  only_if { chef_server_configured? }
end

# If running on Alibaba download the Chef Server package for local installation
url = download_url("chef_server")
target_path = File.join(Chef::Config[:file_cache_path], File.basename(url))
remote_file target_path do
  source url
  only_if { node["chef-marketplace"]["platform"] == "alibaba" }
end

chef_ingredient "chef-server" do
  action :upgrade

  # Use the package sourec if this is running on Alibaba
  package_source target_path if node["chef-marketplace"]["platform"] == "alibaba"

  notifies :run, "bash[chef-server-ctl reconfigure]", :immediately
  notifies :run, "bash[chef-server-ctl upgrade]", :immediately
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

bash "chef-server-ctl restart" do
  code "chef-server-ctl restart"
  only_if { chef_server_configured? }
end
