require "rake"
require "rspec"
require "rspec/core"
require "rspec/core/rake_task"
require "chefstyle"
require "rubocop/rake_task"

desc "Default task to run spec suite"
task default: %w{spec rubocop}

desc "Run chef-marketplace-ctl spec suite"
RSpec::Core::RakeTask.new(:ctl_spec) do |task|
  task.rspec_opts =
    ["-I files/chef-marketplace-ctl-commands/",
     "-I files/chef-marketplace-ctl-commands/spec",
     "-I /opt/chef-marketplace/embedded/service/chef-marketplace-ctl/",
     "-I /opt/chef-marketplace/embedded/service/chef-marketplace-ctl/spec",
     "--format documentation",
     "--color"
    ]

  task.pattern = FileList[
    "{files/chef-marketplace-ctl-commands,/opt/chef-marketplace/embedded/service/chef-marketplace-ctl}/spec/**{,/*/**}/*_spec.rb"
  ]
end

desc "Run chef-marketplace-gem spec suite"
RSpec::Core::RakeTask.new(:gem_spec) do |task|
  task.rspec_opts =
    ["-I files/chef-marketplace-gem/lib/",
     "-I files/chef-marketplace-gem/lib/marketplace",
     "-I files/chef-marketplace-gem/spec",
     "-I files/chef-marketplace-gem/spec/marketplace",
     "-I /opt/chef-marketplace/embedded/service/chef-marketplace-gem/spec",
     "-I /opt/chef-marketplace/embedded/service/chef-marketplace-gem/spec/marketplace",
     "--format documentation",
     "--color"
    ]

  task.pattern = FileList[
    "{files/chef-marketplace-gem,/opt/chef-marketplace/embedded/service/chef-marketplace-gem}/spec/**{,/*/**}/*_spec.rb"
  ]
end

desc "Run all rspec suites"
task spec: %w{ctl_spec gem_spec}

desc "Run Rubocop style checks"
RuboCop::RakeTask.new do |task|
  task.fail_on_error = true
  task.options << "--display-cop-names"
end
