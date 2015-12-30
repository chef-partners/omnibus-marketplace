require 'chef/json_compat'
require 'shellwords'
require 'highline/import'
require 'marketplace/payment'
require 'marketplace/options'
require 'timeout'

# Setup the Marketplace Appliance
class Marketplace
  def self.setup(options, ctl_context)
    Marketplace::Setup.new(options, ctl_context).setup
  end

  # Setup class
  class Setup
    attr_accessor :options, :ui

    def initialize(options, ctl_context)
      options.role = role
      @ui = HighLine.new
      @options = Marketplace::Options.new(options, ui)
      @ctl_context = ctl_context
    end

    def setup
      reconfigure(:marketplace)
      reload_config!
      if options.preconfigure
        # Just configure software if we're preconfiguring
        configure_software
        return
      end
      validate_payment
      validate_options
      ask_for_node_registration
      agree_to_eula
      wait_for_cloud_init_preconfigure
      update_software
      configure_software unless preconfigured?
      create_default_users
      register_node
      redirect_user
    end

    private

    # Use omnibus-ctl methods if they're available
    def method_missing(meth, *args, &block)
      @ctl_context.respond_to?(meth) ? @ctl_context.send(meth, *args, &block) : super
    end

    def configure_software
      case role.to_s
      when 'server'
        reconfigure(:server)
        reconfigure(:manage)
        reconfigure(:reporting)
      when 'analytics'
        reconfigure(:analytics)
      when 'aio'
        reconfigure(:server)
        reconfigure(:manage)
        reconfigure(:reporting)
        reconfigure(:analytics)
      when 'compliance'
        reconfigure(:compliance)
      else
        fail "'#{role}' is not a valid role."
      end
    end

    def create_default_users
      case role.to_s
      when 'server', 'aio'
        create_server_user
        create_server_org
      when 'compliance'
      when 'analytics'
      else
        fail "'#{role}' is not a valid role."
      end
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

    def ssl_port_for(service)
      case service.to_sym
      when :compliance
        marketplace_config['compliance']['ssl_port']
      when :analytics
        marketplace_config['analytics']['ssl_port']
      when :server
        marketplace_config['api_ssl_port']
      else
        fail "Unknown service: #{service}"
      end
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

    def ask_for_node_registration
      return if options.register_node
      msg = "Would you like to register this node with Chef Software to enable Support?\n"
      msg << "Type 'yes' if you agree"

      options.register_node = true if ui.ask("<%= color(%Q(#{msg}), :yellow) %>") =~ /y/i
    end

    def register_node
      return unless options.register_node

      cmd = [
        'chef-marketplace-ctl register-node',
        "-f #{options.first_name.to_s.shellescape}",
        "-l #{options.last_name.to_s.shellescape}",
        "-e #{options.email.to_s.shellescape}",
        "-o #{options.organization.to_s.shellescape}"
      ].join(' ')

      retry_command(cmd, 2, 10)
    end

    def reconfigure(product)
      case product.to_s
      when 'marketplace'
        service_name = 'Chef Marketplace'
        ctl_command = 'chef-marketplace-ctl'
      when 'server'
        service_name = 'Chef Server'
        ctl_command = 'chef-server-ctl'
      when 'manage'
        service_name = 'Chef Manage'
        ctl_command = 'chef-manage-ctl'
      when 'reporting'
        service_name = 'Chef Reporting'
        ctl_command = 'opscode-reporting-ctl'
      when 'analytics'
        service_name = 'Chef Analytics'
        ctl_command = 'opscode-analytics-ctl'
      when 'compliance'
        service_name = 'Chef Compliance'
        ctl_command = 'chef-compliance-ctl'
      else
        fail "Unknown product: #{product}"
      end

      log "Please wait while we set up #{service_name}. This may take a few minutes to complete..."

      # As of 12/29/15 opscode-analytics and opscode-reporting both don't set
      # up these environment variables during the reconfigure chef-client runs.
      # Failing to do so isn't usually a problem because reconfiguring is usually
      # done by a user whose shell environment is passed through.  However, when
      # the command is run by a system user lacking such variables (rc/cloud-init),
      # the reconfigure will fail because rabbitmqctl needs them to be set.
      # Until both packages have been fixed this is our workaround.
      system({ 'HOME' => '/root', 'USER' => 'root' }, "#{ctl_command} reconfigure")
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

    def create_server_user
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

    def create_server_org
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

    # If the instance auto reconfigures at boot via cloud-init then wait
    # until it's finished
    def wait_for_cloud_init_preconfigure
      return unless cloud_init_running?

      log('Please wait for software configuration. This may take a few minutes to complete..')
      Timeout.timeout(900) do
        sleep 5 while cloud_init_running?
      end
    rescue Timeout::Error
      log('Timed out waiting for background configuration to complete', :error)
      exit(1)
    end

    def preconfigured?
      File.exist?('/var/opt/chef-marketplace/preconfigured')
    end

    def cloud_init_running?
      File.exist?('/var/opt/chef-marketplace/cloud_init_running')
    end

    def redirect_user
      msg = ["\n\nYou're all set!\n"]

      case role
      when 'server', 'aio'
        msg << ["Next you'll want to log into the Chef management console and download the Starter Kit:",
                "https://#{fqdn}:#{ssl_port_for(:server)}/organizations/#{options.organization}/getting_started\n",
                "Use your username '#{options.username}' instead of your email address to login\n"
               ]
      when 'compliance'
        msg << ["Next you'll want to log into the Chef Compliance Web UI",
                "https://#{fqdn}:#{ssl_port_for(:compliance)}/#/setup\n"
               ]
      when 'analytics'
        msg << ["Next you'll want to log into the Chef Analytics Web UI",
                "https://#{fqdn}\n",

                "Use your Chef Server username instead of your email address to login\n"
               ]
      end

      msg << 'In order to use Transport Layer Security (TLS) we had to generate a self-signed certificate which'
      msg << "might cause a warning in your browser, you can safely ignore it.\n"

      if role == 'aio'
        msg << "\nGain insight into your infrastructure in the Chef Analytics UI:\n"
        msg << "https://#{fqdn}:#{ssl_port_for(:analytics)}\n\n"
      end

      log(msg.flatten.join("\n"))
    end
  end
end
