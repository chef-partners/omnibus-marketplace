require 'rake'
require 'rspec'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'bundler'
require 'rubocop/rake_task'

desc 'Default task to run spec suite'
task default: %w(spec rubocop)

desc 'Run spec suite '
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts =
    ['-I files/chef-marketplace-ctl-commands/spec',
     '-I files/chef-marketplace-ctl-commands/',
     '-I files/chef-marketplace-ctl-commands/marketplace',
     '-I /opt/chef-marketplace/embedded/service/omnibus-ctl/spec',
     '-I /opt/chef-marketplace/embedded/service/omnibus-ctl/',
     '-I /opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace',
     '--format documentation',
     '--color'
    ]

  task.pattern = FileList['{files/chef-marketplace-ctl-commands,/opt/chef-marketplace/embedded/service/omnibus-ctl}/spec/**{,/*/**}/*_spec.rb']
end

desc 'Run Rubocop style checks'
RuboCop::RakeTask.new do |cop|
  cop.fail_on_error = true
end
