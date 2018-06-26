name "reckoner"
source path: "#{project.files_path}/reckoner"
license :project_license

dependency "ruby"
dependency "bundler"
dependency "chef-marketplace-gem"
dependency "appbundler"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install --without development test doc", env: env
  gem "build reckoner.gemspec", env: env
  gem "install reckoner-*.gem --no-ri --no-rdoc", env: env

  appbundle "reckoner", env: env

  sync project_dir, "#{install_dir}/embedded/service/reckoner/"
end
