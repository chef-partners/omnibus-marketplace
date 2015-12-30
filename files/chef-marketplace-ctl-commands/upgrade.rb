require 'json'

add_command_under_category 'upgrade', 'Configuration', 'Upgrade or install Chef software', 2 do
  config = {
    'chef-marketplace' => {
      'role' => 'aio',
      'upgrade_packages' => []
    },
    'run_list' => ['chef-marketplace::upgrade']
  }

  if File.exist?('/etc/chef-marketplace/chef-marketplace-running.json')
    running_config = JSON.parse(IO.read('/etc/chef-marketplace/chef-marketplace-running.json'))
    config['chef-marketplace']['role'] = running_config['chef-marketplace']['role']
  end

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-marketplace-ctl upgrade [options]'

    opts.on('-y', '--yes', 'Upgrade all installed Chef packages for the configured role') do
      config['chef-marketplace']['upgrade_packages'] << 'chef-marketplace'

      case config['chef-marketplace']['role']
      when 'server'
        config['chef-marketplace']['upgrade_packages'] << 'chef-server'
      when 'analytics'
        config['chef-marketplace']['upgrade_packages'] << 'analytics'
      when 'compliance'
        config['chef-marketplace']['upgrade_packages'] << 'compliance'
      when 'aio'
        config['chef-marketplace']['upgrade_packages'] << 'chef-server'
        config['chef-marketplace']['upgrade_packages'] << 'analytics'
      end
    end

    opts.on('-s', '--server', 'Upgrade Chef Server, Chef Reporting and Chef Manage') do
      config['chef-marketplace']['upgrade_packages'] << 'chef-server'
    end

    opts.on('-a', '--analytics', 'Upgrade Chef Analytics') do
      config['chef-marketplace']['upgrade_packages'] << 'analytics'
    end

    opts.on('-c', '--compliance', 'Upgrade Chef Compliance') do
      config['chef-marketplace']['upgrade_packages'] << 'compliance'
    end

    opts.on('-m', '--marketplace', 'Upgrade Chef Marketplace') do
      config['chef-marketplace']['upgrade_packages'] << 'chef-marketplace'
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit(0)
    end
  end.parse!(ARGV)

  if config['chef-marketplace']['upgrade_packages'].empty?
    puts 'Please specify the component you wish to upgrade.  Run `chef-marketplace-ctl -h` for more information' && exit(1)
  end

  puts "Upgrading packages: #{config['chef-marketplace']['upgrade_packages']}.."

  upgrade_json_file = '/opt/chef-marketplace/embedded/cookbooks/upgrade.json'
  File.write(upgrade_json_file, JSON.pretty_generate(config))
  status = run_chef(upgrade_json_file, '--lockfile /tmp/chef-client-upgrade.lock')
  status.success? ? exit(0) : exit(1)
end
