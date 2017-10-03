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

# If running on Alibaba download the Automate package for local installation
url = download_url("automate")
target_path = File.join(Chef::Config[:file_cache_path], File.basename(url))
remote_file target_path do
  source url
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
