name 'chef-marketplace-ctl'

dependency 'omnibus-ctl'
dependency 'bundler'

source path: "#{project.files_path}/#{name}-commands"

build do
  erb source: 'chef-marketplace-ctl.erb',
      dest: "#{install_dir}/bin/#{name}",
      mode: 0755,
      vars: {
        install_dir: install_dir,
        project_name: project.name
      }

  erb source: 'omnibus-addon-ctl.erb',
      dest: "#{install_dir}/embedded/bin/omnibus-addon-ctl",
      mode: 0755,
      vars: { install_dir: install_dir }

  sync project_dir, "#{install_dir}/embedded/service/omnibus-ctl/"

  bundle 'install --without development', env: with_standard_compiler_flags(with_embedded_path)

  copy "#{Omnibus::Config.project_root}/Rakefile", "#{install_dir}/Rakefile"
end
