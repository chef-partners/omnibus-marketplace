require "json"

RELEASE_CHANNELS = %w(unstable current stable)

add_command_under_category "upgrade", "Maintenance", "Upgrade or install Chef software", 2 do
  config = {
    "chef-marketplace" => {
      "role" => "aio",
      "upgrade_packages" => []
    },
    "run_list" => ["chef-marketplace::upgrade"]
  }

  if File.exist?("/etc/chef-marketplace/chef-marketplace-running.json")
    running_config = JSON.parse(IO.read("/etc/chef-marketplace/chef-marketplace-running.json"))
    config["chef-marketplace"]["role"] = running_config["chef-marketplace"]["role"]
  end

  OptionParser.new do |opts|
    opts.banner = "Usage: chef-marketplace-ctl upgrade [options]"

    opts.on("-y", "--yes", "Upgrade all installed Chef packages for the configured role") do
      config["chef-marketplace"]["upgrade_packages"] << "chef-marketplace"

      case config["chef-marketplace"]["role"]
      when "server"
        config["chef-marketplace"]["upgrade_packages"] << "chef-server-aio"
      when "analytics"
        config["chef-marketplace"]["upgrade_packages"] << "analytics"
      when "compliance"
        config["chef-marketplace"]["upgrade_packages"] << "compliance"
      when "aio"
        config["chef-marketplace"]["upgrade_packages"] << "chef-server-aio"
        config["chef-marketplace"]["upgrade_packages"] << "analytics"
      when "automate"
        config["chef-marketplace"]["upgrade_packages"] << "automate"
        config["chef-marketplace"]["upgrade_packages"] << "chef-server"
      end
    end

    opts.on("-s", "--server", "Upgrade Chef Server, Chef Reporting and Chef Manage") do
      if config["chef-marketplace"]["role"] == "automate"
        config["chef-marketplace"]["upgrade_packages"] << "chef-server"
      else
        config["chef-marketplace"]["upgrade_packages"] << "chef-server-aio"
      end
    end

    opts.on("-a", "--analytics", "Upgrade Chef Analytics") do
      config["chef-marketplace"]["upgrade_packages"] << "analytics"
    end

    opts.on("-c", "--compliance", "Upgrade Chef Compliance") do
      config["chef-marketplace"]["upgrade_packages"] << "compliance"
    end

    opts.on("-m", "--marketplace", "Upgrade Chef Marketplace") do
      config["chef-marketplace"]["upgrade_packages"] << "chef-marketplace"
    end

    opts.on("--override-outbound-traffic", "Override outbound traffic during this command.") do
      config["chef-marketplace"]["override_outbound_traffic"] = true
    end

    opts.on("-d", "--automate", "Upgrade Chef Automate") do
      config["chef-marketplace"]["upgrade_packages"] << "automate"
    end

    opts.on("-r RELEASE_CHANNEL", "--channel RELEASE_CHANNEL", RELEASE_CHANNELS, "Release channel to use for downloading packages to install") do |channel|
      config["chef-marketplace"]["update_channel"] = channel.to_sym
    end

    opts.on("-h", "--help", "Show this message") do
      puts opts
      exit(0)
    end
  end.parse!(ARGV)

  if config["chef-marketplace"]["upgrade_packages"].empty?
    puts "Please specify the component you wish to upgrade.  Run `chef-marketplace-ctl -h` for more information" && exit(1)
  end

  puts "Upgrading packages: #{config['chef-marketplace']['upgrade_packages']}.."

  upgrade_json_file = "/opt/chef-marketplace/embedded/cookbooks/upgrade.json"
  File.write(upgrade_json_file, JSON.pretty_generate(config))
  status = run_chef(upgrade_json_file, "--lockfile /tmp/chef-client-upgrade.lock")
  status.success? ? exit(0) : exit(1)
end
