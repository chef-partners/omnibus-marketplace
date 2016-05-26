name "reckoner"
source path: "#{project.files_path}/reckoner"
license :project_license

dependency "ruby"
dependency "bundler"
dependency "chef-marketplace-gem"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install --path=#{install_dir}/embedded/service/gem", env: env

  sync project_dir, "#{install_dir}/embedded/service/reckoner/"
end
