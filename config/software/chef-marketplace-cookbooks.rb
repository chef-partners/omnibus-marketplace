name 'chef-marketplace-cookbooks'

source path: "#{project.files_path}/#{name}"

dependency 'berkshelf'

build do
  # command "mkdir -p #{install_dir}/embedded/cookbooks"
  # sync "#{project_dir}/", "#{install_dir}/embedded/cookbooks"
  command "#{install_dir}/embedded/bin/berks vendor #{install_dir}/embedded/cookbooks --berksfile=./chef-marketplace/Berksfile",
          env: { 'RUBYOPT'         => nil,
                 'BUNDLE_BIN_PATH' => nil,
                 'BUNDLE_GEMFILE'  => nil,
                 'GEM_PATH'        => nil,
                 'GEM_HOME'        => nil }

  block do
    File.open("#{install_dir}/embedded/cookbooks/dna.json", 'w') do |f|
      f.write(
        JSON.fast_generate(
          run_list: [
            "recipe[#{project.name}::default]"
          ]
        )
      )
    end
    File.open("#{install_dir}/embedded/cookbooks/show-config.json", 'w') do |f|
      f.write(
        JSON.fast_generate(
          run_list: [
            "recipe[#{project.name}::show_config]"
          ]
        )
      )
    end
    File.open("#{install_dir}/embedded/cookbooks/solo.rb", 'w') do |f|
      f.write <<-EOH.gsub(/^ {8}/, '')
        cookbook_path   "#{install_dir}/embedded/cookbooks"
        cache_path "/var/opt/opscode/local-mode-cache"
        file_cache_path "#{install_dir}/embedded/cookbooks/cache"
        verbose_logging true
        ssl_verify_mode :verify_peer
        client_fork false
      EOH
    end
  end
end
