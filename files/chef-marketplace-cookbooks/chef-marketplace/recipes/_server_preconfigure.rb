# Initial configuration times for an entire Chef Server are painfully long due
# to the initial reconfigure chef runs.  This is an experimental attempt to
# preconfigure the services and then remove the default state so as to make
# the initial setup chef run mostly NOOP.  It's a brittle approach, but until
# we have the ability to completely rotate all service keys, passwords, and certs
# then this appears to be the best option to speed up these runs while being
# in compliance with the cloud marketplace rules.

%w(chef-server-ctl opscode-reporting-ctl chef-manage-ctl).each do |ctl_cmd|
  execute "#{ctl_cmd} reconfigure"
end

%w(chef-server-ctl chef-manage-ctl).each do |ctl_cmd|
  execute "#{ctl_cmd} stop"
end

server_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

server_state_directories.each do |state_dir|
  directory state_dir do
    action :delete
    recursive true
  end
end

execute 'recreate server runit directories' do
  command 'mkdir -p /opt/{opscode,chef-manage}/{sv,init,service}'
end
