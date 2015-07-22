name 'chef-marketplace-cookbooks'

source path: File.expand_path("files/#{project.name}-cookbooks", Omnibus::Config.project_root)

build do
  command "mkdir -p #{install_dir}/embedded/cookbooks"
  sync "#{project_dir}/", "#{install_dir}/embedded/cookbooks"
end
