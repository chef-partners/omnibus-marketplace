%w(chef-server-ctl opscode-reporting-ctl chef-manage-ctl opscode-analytics-ctl).each do |ctl_cmd|
  execute "#{ctl_cmd} reconfigure"
end

%w(chef-server-ctl chef-manage-ctl opscode-analytics-ctl).each do |ctl_cmd|
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

analytics_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

analytics_state_directories.each do |state_dir|
  directory state_dir do
    action :delete
    recursive true
  end
end
