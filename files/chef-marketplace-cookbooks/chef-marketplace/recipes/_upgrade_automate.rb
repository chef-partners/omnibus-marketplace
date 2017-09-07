# Possibly run actions
bash 'delivery-ctl reconfigure' do
  code 'delivery-ctl reconfigure'
  only_if { delivery_configured? }
  action :nothing
end

bash 'delivery-ctl start' do
  code 'delivery-ctl start'
  only_if { delivery_configured? }
  action :nothing
end

# Chef Automate

# Download the package for installation if running on Alibaba
if node["chef-marketplace"].key?("product_urls") &&
   node["chef-marketplace"]["product_urls"].key?("automate")
  target_path = File.join(Chef::Config[:file_cache_path], File.basename(node["chef-marketplace"]["product_urls"]["automate"]))
end
remote_file target_path do
  source node["chef-marketplace"]["product_urls"]["automate"]

  only_if { node["chef-marketplace"]["platform"] == "alibaba" }
end

chef_ingredient 'delivery' do
  action :upgrade

  # Use the package sourec if this is running on Alibaba
  package_source target_path if node["chef-marketplace"]["platform"] == "alibaba"

  notifies :run, 'bash[delivery-ctl reconfigure]', :immediately
  notifies :run, 'bash[yum-clean-all]', :immediately
  notifies :run, 'bash[apt-get-clean]', :immediately
end

bash 'delivery-ctl restart' do
  code 'delivery-ctl restart'
  only_if { delivery_configured? }
end
