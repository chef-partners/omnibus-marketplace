name 'chef-marketplace-ctl'

dependency 'omnibus-ctl'

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
end
