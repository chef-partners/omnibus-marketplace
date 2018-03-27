name "biscotti"
source path: "#{project.files_path}/biscotti"

license :project_license

dependency "ruby"
dependency "bundler"
dependency "nodejs-binary"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  # Make sure we know where to find npm so that we can build the assets
  env["PATH"] = "#{env["PATH"]}:#{install_dir}/embedded/nodejs/bin"

  bundle "install --path=#{install_dir}/embedded/service/gem", env: env
  command "rm -rf node_modules/* && " \
          "npm install -g @angular/cli && " \
          "npm install && " \
          "ng build --prod", env: env
  sync project_dir, "#{install_dir}/embedded/service/biscotti/", exclude: "node_modules"
end
