# Hacks to get around using helpers with omnibus-ctl
begin
  require 'marketplace/setup'
rescue LoadError
  require '/opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace/setup'
end

add_command_under_category 'setup', 'Configuration', 'Set up the Chef Server Marketplace Appliance', 2 do
  options = OpenStruct.new
  options.agree_to_eula = false

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-server-ctl marketplace-setup [options]'

    opts.on('-y', '--yes', 'Agree to the Chef End User License Agreement') do
      options.agree_to_eula = true
    end

    opts.on('-u USERNAME', '--username USERNAME', String, 'Your Admin username') do |username|
      options.username = username
    end

    opts.on('-p PASSWORD', '--password PASSWORD', String, 'Your password') do |password|
      options.password = password
    end

    opts.on('-f FIRSTNAME', '--firstname FIRSTNAME', String, 'Your first name') do |first_name|
      options.first_name = first_name
    end

    opts.on('-l LASTNAME', '--lastname LASTNAME', String, 'Your last name') do |last_name|
      options.last_name = last_name
    end

    opts.on('-e EMAIL', '--email EMAIL', String, 'Your email address') do |email|
      options.email = email
    end

    opts.on('-o ORGNAME', '--org ORGNAME', String, 'Your organization name') do |org|
      options.organization = org
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end.parse!(ARGV)

  Marketplace.setup(options, self)
end
