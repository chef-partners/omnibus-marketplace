name "server-plugin-cookbooks"

source path: "#{project.files_path}/#{name}"

build do
  sync project_dir, "#{install_dir}/embedded/server-plugin-cookbooks/"
end
