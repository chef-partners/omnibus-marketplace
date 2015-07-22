name 'chef-marketplace'

source path: File.expand_path("files/#{project_name}", Omnibus::Config.project_root)

relative_path 'chef-marketplace'

build do
  command "mkdir -p #{install_dir}/embedded/service/chef-marketplace"
  sync "#{project_dir}", "#{install_dir}/embedded/service/chef-marketplace", exclude: ['README.md', 'test', '.git']

  block do
    File.open("#{install_dir}/chef-server-plugin.rb", 'w') do |f|
      f.puts <<EOF
plugin "chef-marketplace-aws" do
  cookbook_path "/opt/chef-marketplace/embedded/cookbooks"
  enabled_by_default true
end
EOF
    end
  end
end
