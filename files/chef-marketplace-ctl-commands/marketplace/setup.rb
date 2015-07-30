require 'optparse'
require 'ostruct'
require 'chef/json_compat'
require 'ohai/system'
require 'shellwords'
# Hacks to get around using helpers with omnibus-ctl
begin
  require_relative 'payment'
rescue LoadError
  require '/opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace/payment'
end
begin
  require_relative 'options'
rescue LoadError
  require '/opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace/options'
end

# Setup the Marketplace Appliance
class Marketplace
  def self.setup(options, ctl_context)
    Marketplace::Setup.new(options, ctl_context).setup
  end

  # Setup class
  class Setup
    attr_accessor :options, :ohai

    def initialize(options, ctl_context)
      @options = Marketplace::Options.new(options)
      @ctl_context = ctl_context
      @ohai = Ohai::System.new.all_plugins.first.data
    end

    def setup
      validate_payment
      validate_options
      agree_to_eula
      update_fqdn
      reconfigure_chef_server
      create_default_user
      create_default_org
      reconfigure_webui
      reconfigure_reporting
      redirect_to_webui
    end

    private

    # Use omnibus-ctl methods if they're available
    def method_missing(meth, *args, &block)
      @ctl_context.respond_to?(meth) ? @ctl_context.send(meth, *args, &block) : super
    end

    # Some marketplaces have ways for the instance to determine if the instance
    # is running a paid image.  At build time we'll drop a validatation file
    # onto the filesystem that implements a class that will do the validations.
    def validate_payment
      Marketplace::Payment.validate if defined?(Marketplace::Payment)
    end

    def validate_options
      options.validate
    end

    def agree_to_eula
      return if options.agree_to_eula
      msg = 'By continuing you agree to be held to the terms of the '
      msg << 'Chef Software, Inc. License Agreement, as detailed here: '
      msg << "https://www.chef.io/online-master-agreement/\n"
      msg << 'Type \'yes\' if you agree'

      unless ask(msg) =~ /yes/i
        puts 'You must agree to the Chef Software, Inc License Agreement in order to continue.'
        exit 1
      end
    end

    def update_fqdn
      api_fqdn = ohai['fqdn'] unless ohai.key?('cloud_v2')
      api_fqdn ||=
        case ohai['cloud_v2']['provider']
        when 'gce'
          ohai['cloud_v2']['public_ipv4']
        when 'azure'
          "#{ohai['cloud_v2']['public_hostname']}.cloudapp.net"
        else
          ohai['cloud_v2']['public_hostname'] || ohai['cloud_v2']['local_hostname'] || ohai['fqdn']
        end

      ::File.open('/etc/opscode/chef-server.rb', 'a+') do |f|
        f.puts "api_fqdn '#{api_fqdn}'" unless f.read =~ /api_fqdn/
      end
    end

    def reconfigure_chef_server
      puts 'Please wait while we set up the Chef Server. This may take a few minutes to complete'
      run_command('chef-server-ctl reconfigure')
    end

    def reconfigure_reporting
      run_command('opscode-reporting-ctl reconfigure')
    end

    def reconfigure_webui
      run_command('opscode-manage-ctl reconfigure')
    end

    def create_default_user
      cmd = [
        'chef-server-ctl user-create',
        options.username.to_s.shellescape,
        options.first_name.to_s.shellescape,
        options.last_name.to_s.shellescape,
        options.email.to_s.shellescape,
        options.password.to_s.shellescape
      ].join(' ')

      retry_command(cmd)
    end

    def create_default_org
      cmd = [
        'chef-server-ctl org-create',
        options.organization.to_s.shellescape,
        options.organization.to_s.shellescape,
        '-a',
        options.username.to_s.shellescape
      ].join(' ')

      retry_command(cmd)
    end

    def retry_command(cmd, retries = 5, seconds = 2)
      retries.times do
        return if run_command(cmd).success?
        puts "#{cmd} failed, retrying..."
        sleep seconds
      end
      false
    end

    def redirect_to_webui
      chef_running = Chef::JSONCompat.parse(File.read('/etc/opscode/chef-server-running.json'))
      fqdn = chef_running['private_chef']['lb']['api_fqdn']
      msg = [
        "\n\nYou're all set!\n",
        "Next you'll want to log into the Chef management console and download the Starter Kit:",
        "https://#{fqdn}/organizations/#{options.organization}/getting_started\n",
        'In order to use Transport Layer Security (TLS) we had to generate a self-signed certificate which',
        "might cause a warning in your browser, you can safely ignore it.\n",
        "Use your username '#{options.username}' instead of your email address to login\n"
      ].join("\n")

      puts(msg)
    end
  end
end
