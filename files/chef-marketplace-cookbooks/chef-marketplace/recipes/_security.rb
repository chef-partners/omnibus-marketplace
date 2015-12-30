%w(openssh-clients openssh-server).each do |pkg|
  package pkg do
    action :install
    only_if { mirrors_reachable? }
  end
end

template '/etc/ssh/sshd_config' do
  source 'sshd-config.erb'
  mode '0600'
  owner 'root'
  group 'root'
end

service 'sshd' do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end

current_user_directories.each do |usr, dir|
  %w(id_rsa id_rsa.pub authorized_keys).each do |ssh_file|
    file ::File.join(dir, '.ssh', ssh_file) do
      action :delete
    end
  end

  user usr do
    action :lock
  end

  file ::File.join(dir, '.bash_history') do
    action :delete
  end
end

system_ssh_keys.each do |key|
  file key do
    action :delete
  end
end

current_sudoers.each do |sudo_user|
  file sudo_user do
    action :delete
  end
end

%w(/etc/chef/client.rb /etc/chef/client.pem).each do |chef_file|
  file chef_file do
    action :delete
  end
end

directory '/var/log' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/tmp' do
  owner 'root'
  group 'root'
  mode '1777'
  action :create
end

directory '/var/opt/chef-marketplace' do
  action :delete
  recursive true
end

execute 'rm -rf /tmp/*' do
  not_if { Dir['/tmp/*'].empty? }
end

execute 'rm -rf /var/log/*' do
  not_if { Dir['/var/log/*'].empty? }
end
