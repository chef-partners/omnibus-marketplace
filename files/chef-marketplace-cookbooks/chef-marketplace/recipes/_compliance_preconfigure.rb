execute 'chef-compliance-ctl reconfigure'
execute 'chef-compliance-ctl stop'

compliance_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

compliance_state_directories.each do |state_dir|
  directory state_dir do
    action :delete
    recursive true
  end
end

execute 'recreate complinace runit directories' do
  command 'mkdir -p /opt/chef-compliance/{sv,init,service}'
end
