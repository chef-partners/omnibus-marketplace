name "pg-gem"
default_version "0.18.4"

dependency "ruby"
dependency "rubygems"
dependency "postgresql92"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "install pg" \
      " -i #{install_dir}/embedded/service/gem/ruby/2.2.0" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/service/gem/ruby/2.2.0/bin/'" \
      " --no-ri --no-rdoc" \
      " -- --with-pg-config=#{install_dir}/embedded/bin/pg_config", env: env
end
