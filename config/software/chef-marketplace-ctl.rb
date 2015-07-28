name 'chef-marketplace-ctl'

dependency 'omnibus-ctl'

source path: "#{project.files_path}/#{name}-commands"

build do
  block do
    open("#{install_dir}/bin/#{name}", 'w') do |file|
      file.print <<-EOH
#!/bin/bash
#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Ensure the calling environment (disapproval look Bundler) does not infect our
# Ruby environment if called from a Ruby script.
for ruby_env_var in RUBYOPT \\
                    BUNDLE_BIN_PATH \\
                    BUNDLE_GEMFILE \\
                    GEM_PATH \\
                    GEM_HOME
do
  unset $ruby_env_var
done

#{install_dir}/embedded/bin/omnibus-addon-ctl #{project.name} #{install_dir}/embedded/service/omnibus-ctl $@
       EOH
    end
  end

  command "chmod 755 #{install_dir}/bin/#{name}"

  block do
    open("#{install_dir}/embedded/bin/omnibus-addon-ctl", 'w') do |file|
      file.print <<-EOH
#!#{install_dir}/embedded/bin/ruby
#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'omnibus-ctl'
ctl = Omnibus::Ctl.new(ARGV[0], service_commands=false)
ctl.load_files(ARGV[1])
arguments = []
arguments << ARGV[2] if !ARGV[2].nil?
arguments << ARGV[3] if !ARGV[3].nil?
ctl.run(arguments)
exit 0
       EOH
    end
  end

  command "chmod 755 #{install_dir}/embedded/bin/omnibus-addon-ctl"

  sync project_dir, "#{install_dir}/embedded/service/omnibus-ctl/"
end
