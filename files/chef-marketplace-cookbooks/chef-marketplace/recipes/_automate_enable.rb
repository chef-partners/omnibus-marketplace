include_recipe 'chef-marketplace::_server_enable'

directory '/etc/delivery'

private_key '/etc/delivery/delivery.pem' do
  cipher            'DES-EDE3-CBC'
  format            :pem
  public_key_format :openssh
  public_key_path   '/etc/delivery/delivery.pub'
  size              2048
  type              :rsa
end

private_key '/etc/delivery/builder.pem' do
  cipher            'DES-EDE3-CBC'
  format            :pem
  public_key_format :openssh
  public_key_path   '/etc/delivery/builder.pub'
  size              2048
  type              :rsa
end

# TODO: reconfigure delivery when templates change
template '/etc/delivery/delivery.rb' do
  source 'delivery.rb.erb'
end

directory '/var/opt/delivery/license' do
  recursive true
end

# Use a 30 day trial license if we're on Azure
cookbook_file 'var/opt/delivery/license/delivery.license' do
  source 'delivery.license'
  action :create_if_missing
  only_if { node['chef-marketplace']['platform'] == 'azure' }
end
