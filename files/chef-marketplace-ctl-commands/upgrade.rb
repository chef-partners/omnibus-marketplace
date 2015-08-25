require 'ostruct'

add_command_under_category 'upgrade', 'Configuration', 'Upgrade or install Chef Server software', 2 do
  options = OpenStruct.new
  options.upgrade_marketplace = false
  options.upgrade_chef_server = false

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-marketplace-ctl upgrade [options]'

    opts.on('-y', '--yes', 'Agree to upgrade Chef Server, Marketplace, Reporting and Manage') do
      options.upgrade_marketplace = true
      options.upgrade_chef_server = true
    end

    opts.on('-s', '--server', 'Agree to upgrade the Chef Server, Reporting and Manage') do
      options.upgrade_chef_server = true
    end

    opts.on('-m', '--marketplace', 'Agree to upgrade the Chef Marketplace addon') do
      options.upgrade_marketplace = true
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit(0)
    end
  end.parse!(ARGV)

  unless options.upgrade_marketplace || options.upgrade_chef_server
    puts 'Please specify the component you wish to upgrade.  Run `chef-marketplace-ctl -h` for more information' && exit(1)
  end

  if options.upgrade_marketplace
    puts 'Upgrading the Chef Server Marketplace Add-On...'
    marketplace_status = run_chef("#{base_path}/embedded/cookbooks/upgrade-marketplace.json", '--lockfile /tmp/chef-client-upgrade.lock')
    exit(1) unless marketplace_status.success?
  end

  if options.upgrade_chef_server
    puts 'Upgrading the Chef Server, Manage and Reporting...'
    chef_server_status = run_chef("#{base_path}/embedded/cookbooks/upgrade-chef-server.json", '--lockfile /tmp/chef-client-upgrade.lock')
    exit(1) unless chef_server_status.success?
  end

  exit(0)
end
