name 'server-plugin-cookbooks'

source path: "#{project.files_path}/#{name}"

dependency 'berkshelf'

build do
  command "#{install_dir}/embedded/bin/berks vendor #{install_dir}/embedded/server-plugin-cookbooks --berksfile=./chef-marketplace/Berksfile",
          env: { 'RUBYOPT'         => nil,
                 'BUNDLE_BIN_PATH' => nil,
                 'BUNDLE_GEMFILE'  => nil,
                 'GEM_PATH'        => nil,
                 'GEM_HOME'        => nil }
end
