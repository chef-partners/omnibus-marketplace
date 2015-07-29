name 'chef-marketplace'

# Hook into chef-server-ctl reconfigure as a plugin
build do
  erb source: 'chef-server-plugin.rb.erb',
      dest: "#{install_dir}/chef-server-plugin.rb"
end
