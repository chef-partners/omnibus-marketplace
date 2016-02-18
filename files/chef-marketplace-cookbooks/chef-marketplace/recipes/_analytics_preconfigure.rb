bash 'opscode-analytics-ctl reconfigure'
bash 'opscode-analytics-ctl stop'

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

bash 'recreate analytics runit directories' do
  command 'mkdir -p /opt/opscode-analytics/{sv,init,service}'
end
