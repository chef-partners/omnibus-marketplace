require 'ostruct'

add_command_under_category 'upgrade', 'Configuration', 'Upgrade or install Chef Server software', 2 do
  options = OpenStruct.new
  options.upgrade_marketplace = false
  options.upgrade_chef_server = false
  options.upgrade_analytics = false
  role = 'aio'

  if File.exist?('/etc/chef-marketplace/chef-marketplace-running.json')
    role = JSON.parse(IO.read('/etc/chef-marketplace/chef-marketplace-running.json'))['chef-marketplace']['role']
  end

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-marketplace-ctl upgrade [options]'

    opts.on('-y', '--yes', 'Upgrade all installed Chef packages') do
      options.upgrade_marketplace = true

      case role
      when 'server'
        options.upgrade_chef_server = true
      when 'analytics'
        options.upgrade_analytics = true
      when 'aio'
        options.upgrade_chef_server = true
        options.upgrade_analytics = true
      end
    end

    opts.on('-s', '--server', 'Upgrade Chef Server, Chef Reporting and Chef Manage') do
      options.upgrade_chef_server = true
    end

    opts.on('-a', '--analytics', 'Upgrade Chef Analytics') do
      options.upgrade_analytics = true
    end

    opts.on('-m', '--marketplace', 'Upgrade Chef Marketplace') do
      options.upgrade_marketplace = true
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit(0)
    end
  end.parse!(ARGV)

  unless options.upgrade_marketplace || options.upgrade_chef_server || options.upgrade_analytics
    puts 'Please specify the component you wish to upgrade.  Run `chef-marketplace-ctl -h` for more information' && exit(1)
  end

  if options.upgrade_marketplace
    puts 'Upgrading Chef Marketplace...'
    marketplace_status = run_chef("#{base_path}/embedded/cookbooks/upgrade-marketplace.json", '--lockfile /tmp/chef-client-upgrade.lock')
    exit(1) unless marketplace_status.success?
  end

  if options.upgrade_chef_server
    puts 'Upgrading Chef Server, Chef Manage and Chef Reporting...'
    chef_server_status = run_chef("#{base_path}/embedded/cookbooks/upgrade-chef-server.json", '--lockfile /tmp/chef-client-upgrade.lock')
    exit(1) unless chef_server_status.success?
  end

  if options.upgrade_analytics
    puts 'Upgrading Chef Analytics...'
    analytics = run_chef("#{base_path}/embedded/cookbooks/upgrade-analytics.json", '--lockfile /tmp/chef-client-upgrade.lock')
    exit(1) unless analytics.success?
  end

  exit(0)
end
