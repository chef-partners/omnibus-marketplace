# Hacks to get around using helpers with omnibus-ctl
begin
  require 'marketplace/hostname'
rescue LoadError
  require '/opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace/hostname'
end

add_command_under_category 'hostname', 'Configuration', 'Query and modify the hostname', 2 do
  @eip = false
  marketplace = Marketplace::Hostname.new
  user_args = ARGV[3..-1] || []
  # Switches start with a dash but our hostname shouldn't..
  hostname = user_args.find { |a| a !~ /^\-/ }

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-marketplace-ctl hostname [HOSTNAME] [options]'

    opts.on('-e', '--associate-eip', 'Associate an Elastic IP Address') do
      @eip = true
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end.parse!(ARGV)

  if @eip
    puts 'ERROR: You must provide a hostname when associating an EIP' && exit(1) unless hostname
    marketplace.associate_eip(hostname)
  end

  if hostname
    puts "Configuring the hostname to: #{hostname}.."
    marketplace.write_chef_json('/opt/chef-marketplace/embedded/cookbooks/update-hostname.json', hostname)
    run_chef('/opt/chef-marketplace/embedded/cookbooks/update-hostname.json')
  else
    fqdn = marketplace.resolve
    msg = 'ERROR: The Chef Server requires a resolvable fully qualified domain name.'
    msg << 'You can attempt to associate a FQDN by running: chef-marketplace-ctl hostname your.hostname.com'
    puts msg && exit(1) unless fqdn
    puts fqdn
  end

  exit(0)
end
