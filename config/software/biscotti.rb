name 'biscotti'
source path: "#{project.files_path}/biscotti"

dependency 'ruby'
dependency 'bundler'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install --path=#{install_dir}/embedded/service/gem", env: env

  sync project_dir, "#{install_dir}/embedded/service/biscotti/"
end
