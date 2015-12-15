require 'highline/import'

add_command_under_category 'register-node', 'Configuration', 'Register node with Chef to enable support', 2 do
  config = {
    'chef-marketplace' => {
      'registration' => {
        'address' => 'marketplace.chef.io'
      }
    },
    'run_list' => ['chef-marketplace::register_node']
  }

  ui = HighLine.new

  if File.exist?('/etc/chef-marketplace/chef-marketplace-running.json')
    running_config = JSON.parse(IO.read('/etc/chef-marketplace/chef-marketplace-running.json'))
    config['chef-marketplace']['registration']['address'] = running_config['chef-marketplace']['marketplace_api']['address']
  end

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-marketplace-ctl register-node [options]'

    opts.on('-f FIRST_NAME', '--first FIRST_NAME', String, 'The primary support contacts first name') do |first|
      config['chef-marketplace']['registration']['first_name'] = first
    end

    opts.on('-l LAST_NAME', '--last LAST_NAME', String, 'The primary support contacts last name') do |last|
      config['chef-marketplace']['registration']['last_name'] = last
    end

    opts.on('-e EMAIL_ADDRESS', '--email EMAIL_ADDRESS', String, 'The primary support contacts email address') do |email|
      config['chef-marketplace']['registration']['email'] = email
    end

    opts.on('-o ORG_NAME', '--organization ORG_NAME', String, 'The primary support contacts organization name') do |org|
      config['chef-marketplace']['registration']['organization'] = org
    end

    opts.on('-s SERVER_ADDRESS', '--server SERVER_ADDRESS', String, 'The Marketplace API server address') do |address|
      config['chef-marketplace']['registration']['address'] = address
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end.parse!(ARGV)

  %w(first_name last_name organization).each do |opt|
    config['chef-marketplace']['registration'][opt] ||= ui.ask("Please enter your #{opt.split('_').first} name:") do |q|
      q.validate = ->(p) { p.length >= 3 }
      q.responses[:not_valid] = 'Valid entries must be at least 3 characters in length'
    end
  end

  config['chef-marketplace']['registration']['email'] ||= ui.ask('Please enter your email address:') do |q|
    q.validate = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    q.responses[:not_valid] = 'Your entry was not a valid email address'
  end

  puts 'Registering the node with Chef Software...'

  register_json_file = '/opt/chef-marketplace/embedded/cookbooks/register_node.json'
  File.write(register_json_file, JSON.pretty_generate(config))
  status = run_chef(register_json_file, '--lockfile /tmp/chef-client-register-node.lock')
  status.success? ? exit(0) : exit(1)
end
