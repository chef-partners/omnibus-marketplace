name 'chef-marketplace'

build do
  block do
    File.open("#{install_dir}/chef-server-plugin.rb", 'w') do |f|
      f.puts <<EOF
plugin "chef-marketplace" do
  cookbook_path "/opt/chef-marketplace/embedded/cookbooks"
  enabled_by_default true
end
EOF
    end
  end
end
