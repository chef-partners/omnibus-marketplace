name "biscotti"
source path: "#{project.files_path}/biscotti"

license :project_license

dependency "ruby"
dependency "bundler"
dependency "nodejs-binary"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install --path=#{install_dir}/embedded/service/gem", env: env
  bundle "exec rake assets:precompile", env: env
  sync project_dir, "#{install_dir}/embedded/service/biscotti/", exclude: "node_modules"
end
