include_recipe "chef-marketplace::_server_enable"

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

# TODO:
# * reconfigure delivery when templates change

template "/etc/delivery/delivery.rb" do
  source "delivery.rb.erb"
end
