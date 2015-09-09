require 'chef/json_compat'
require 'ohai/system'
require 'shellwords'
require 'highline/import'
# Hacks to get around using helpers with omnibus-ctl
begin
  require 'payment'
rescue LoadError
  require '/opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace/payment'
end
begin
  require 'options'
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
    attr_accessor :options, :ohai, :ui

    def initialize(options, ctl_context)
      options.role = role
      @ui = HighLine.new
      @options = Marketplace::Options.new(options, ui)
      @ctl_context = ctl_context
    end

    def setup
      reconfigure_marketplace
      reload_config!
      validate_payment
      validate_options
      agree_to_eula
      update_software

      case role
      when 'server' then setup_server
      when 'analytics' then setup_analytics
      when 'aio' then setup_aio
      else
        fail "'#{role}' is not a valid role."
      end

      redirect_to_webui if role =~ /aio|server/
    end

    private

    # Use omnibus-ctl methods if they're available
    def method_missing(meth, *args, &block)
      @ctl_context.respond_to?(meth) ? @ctl_context.send(meth, *args, &block) : super
    end

    def setup_server
      reconfigure_chef_server
      create_default_user
      create_default_org
      reconfigure_webui
      reconfigure_reporting
    end

    def setup_analytics
      # The preflight-check is currently broken because curl isn't in the package
      # run_analytics_preflight_check
      reconfigure_analytics
    end

    def setup_aio
      setup_server
      setup_analytics
    end

    def reload_config!
      @marketplace_config = nil
      marketplace_config
    end

    def marketplace_config
      @marketplace_config ||= begin
        marketplace_json = '/etc/chef-marketplace/chef-marketplace-running.json'
        if File.exist?(marketplace_json)
          Chef::JSONCompat.parse(IO.read(marketplace_json))['chef-marketplace']
        else
          {}
        end
      end
    end

    def role
      if marketplace_config.key?('role')
        marketplace_config['role']
      else
        msg = "Could not determine the Chef Marketplace role.\n"
        msg << "Please set the role in /etc/chef-marketplace/marketplace.rb\n"
        msg << "and run 'chef-marketplace-ctl reconfigure'."
        log(msg, :error)
        exit(1)
      end
    end

    def fqdn
      marketplace_config['api_fqdn']
    end

    def analytics_ssl_port
      marketplace_config['analytics']['ssl_port']
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
      msg = "By continuing you agree to be held to the terms of the\n"
      msg << "Chef Software, Inc. License Agreement, as detailed here:\n"
      msg << "https://www.chef.io/online-master-agreement/\n"
      msg << "Type 'yes' if you agree"

      unless ui.ask("<%= color(%Q(#{msg}), :yellow) %>") =~ /yes/i
        log('You must agree to the Chef Software, Inc License Agreement in order to continue.', :error)
        exit 1
      end
    end

    def reconfigure_chef_server
      log 'Please wait while we set up the Chef Server. This may take a few minutes to complete...'
      run_command('chef-server-ctl reconfigure')
    end

    def reconfigure_reporting
      log 'Please wait while we set up Chef Reporting...'
      run_command('opscode-reporting-ctl reconfigure')
    end

    def reconfigure_webui
      log 'Please wait while we set up Chef Manage...'
      run_command('opscode-manage-ctl reconfigure')
    end

    def reconfigure_analytics
      log 'Please wait while we set up Chef Analytics. This may take a few minutes to complete...'
      run_command('opscode-analytics-ctl reconfigure')
    end

    def reconfigure_marketplace
      log 'Please wait while we set up Chef Marketplace...'
      run_command('chef-marketplace-ctl reconfigure')
    end

    def run_analytics_preflight_check
      unless run_command('opscode-analytics preflight-check').success?
        log('Chef Analtyics preflight check failed, cannot set up Chef Analytics', :error)
        exit 1
      end
    end

    def update_software
      log 'Updating the Chef Server software packages...'
      run_command('chef-marketplace-ctl upgrade -y')
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
        ui.say("#{cmd} failed, retrying...")
        sleep seconds
      end
      false
    end

    def log(msg, severity = :info)
      case severity
      when :info
        ui.say("<%= color(%Q(#{msg}), :green) %>")
      when :warn
        ui.say("<%= color('WARNING: ', :yellow) %> #{msg}")
      when :error
        ui.say("<%= color('ERROR: ', :red) %> #{msg}")
      else
        ui.say(msg)
      end
    end

    def redirect_to_webui
      msg = [
        "\n\nYou're all set!\n",
        "Next you'll want to log into the Chef management console and download the Starter Kit:",
        "https://#{fqdn}/organizations/#{options.organization}/getting_started\n",
        "Use your username '#{options.username}' instead of your email address to login\n",
        'In order to use Transport Layer Security (TLS) we had to generate a self-signed certificate which',
        "might cause a warning in your browser, you can safely ignore it.\n"
      ].join("\n")

      if role == 'aio'
        msg << "\nGain insight into your infrastructure in the Chef Analytics UI:\n"
        msg << "https://#{fqdn}:#{analytics_ssl_port}\n\n"
      end

      log(msg)
    end
  end
end
