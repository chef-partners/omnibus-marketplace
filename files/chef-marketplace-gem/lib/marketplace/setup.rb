require "chef/json_compat"
require "mixlib/shellout"
require "shellwords"
require "highline/import"
require "open-uri"
require "base64"
require "marketplace/payment"
require "marketplace/options"
require "timeout"

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
        # Disable biscotti until Automate is setup so the user can't try to
        # create users or a starter kit before Automate and Server are good
        # to go.
        retry_command("chef-marketplace-ctl stop biscotti", retries: 2)

        # Just configure software if we're preconfiguring
        setup_license if role.to_s == "automate"
        configure_software
        reconfigure(:marketplace)
        setup_automate if role.to_s == "automate"
        retry_command("chef-marketplace-ctl start biscotti", retries: 2)
        restart_reckoner
        return
      end
      validate_options
      ask_for_node_registration
      agree_to_eula
      wait_for_cloud_init_preconfigure
      update_software
      configure_software unless preconfigured?
      create_default_users
      restart_reckoner
      register_node
      redirect_user
    end

    private

    # Use omnibus-ctl methods if they're available
    def method_missing(meth, *args, &block)
      @ctl_context.respond_to?(meth) ? @ctl_context.send(meth, *args, &block) : super
    end

    def setup_automate
      # NOTE: because this code is part of a CLI tool and not a recipe
      # like most of the code exectuted by `chef-marketplace-ctl`, we
      # don't have access to node attributes that are set by the -ctl
      # commands. Eventually, this CLI app should move into a recipe
      # like the rest of the commands beause it's no longer useful to
      # be run from the CLI any more.

      passwords = marketplace_secrets["automate"]["passwords"]

      # create chef server user
      # TODO:
      # * determine correct email
      # * create user with existing delivery.{pem,pub}
      create_user = [
        "chef-server-ctl",
        "user-create",
        "delivery",                         # options.username,
        "Automate",                         # options.first_name,
        "User",                             # options.last_name,
        "automate@chef.io",                 # options.email,
        passwords["chef_user"],             # options.password
        "-f", "/etc/delivery/delivery.pem",
      ].shelljoin
      retry_command(create_user, retries: 1)

      # create chef server org
      create_org = [
        "chef-server-ctl",
        "org-create",
        "delivery",       # options.organization,
        "delivery",       # options.organization,
        "-a", "delivery"  # options.username
      ].shelljoin
      retry_command(create_org, retries: 1)

      # Try to wait for automate to come up before attempting to create the
      # automate enterprise. This has the added bonus of being able to log
      # the state of all the services while we wait.
      retry_command("delivery-ctl status", retries: 60, seconds: 2) # Wait up to two minutes.

      # create automate enterprise
      create_ent = [
        "delivery-ctl",
        "create-enterprise",
        "default",                                                    # enterprise name
        "--ssh-pub-key-file=/etc/delivery/builder.pub",               # builder public key
        "--password=#{passwords['admin_user']}",                      # admin password
        "--builder-password=#{passwords['builder_user']}"             # builder password
      ].shelljoin
      retry_command(create_ent, retries: 3, seconds: 10)
    end

    #
    # If either of the initial license setup options have been passed via the
    # CLI then we need to try and setup the initial license.
    #
    def setup_license
      license_path = "/var/opt/delivery/license/delivery.license"
      FileUtils.mkdir_p(File.dirname(license_path))

      if options.license_url
        open(URI(options.license_url.to_s)) do |body|
          File.open(license_path, "w+") do |file|
            file.write(body.read)
          end
        end
      end

      if options.license_base64
        File.open(license_path, "w+") do |file|
          file.write(Base64.decode64(options.license_base64.to_s))
        end
      end
    end

    #
    # Some versions of the Chef Server have a bug where a database preflight
    # check will fail when using external postgres.
    #
    # https://github.com/chef/chef-server/pull/1264
    #
    # It's been fixed but has not been released. After that is the case we
    # can remove this step.
    #
    def setup_chef_server_pg_password
      # Touch the secrets file
      chef_secrets_file = "/etc/opscode/private-chef-secrets.json"
      FileUtils.mkdir_p(File.dirname(chef_secrets_file))
      FileUtils.touch(chef_secrets_file)

      # Set the superuser password
      db_superuser_password = marketplace_secrets["automate"]["postgresql"]["superuser_password"]
      command = "chef-server-ctl set-db-superuser-password #{db_superuser_password} --yes"
      retry_command(command, retries: 1)
    end

    def configure_software
      case role.to_s
      when "server"
        reconfigure(:server)
        reconfigure(:manage)
        reconfigure(:reporting)
      when "analytics"
        reconfigure(:analytics)
      when "aio"
        reconfigure(:server)
        reconfigure(:manage)
        reconfigure(:reporting)
        reconfigure(:analytics)
      when "compliance"
        reconfigure(:compliance)
      when "automate"
        reconfigure(:delivery)
        setup_chef_server_pg_password
        reconfigure(:server)
      else
        raise "'#{role}' is not a valid role."
      end
    end

    def create_default_users
      case role.to_s
      when "server", "aio", "automate"
        create_server_user
        create_server_org
      when "compliance"
      when "analytics"
      else
        raise "'#{role}' is not a valid role."
      end
    end

    def reload_config!
      @marketplace_config = nil
      marketplace_config
    end

    def marketplace_config
      @marketplace_config ||= begin
        marketplace_json = "/etc/chef-marketplace/chef-marketplace-running.json"
        if File.exist?(marketplace_json)
          Chef::JSONCompat.parse(IO.read(marketplace_json))["chef-marketplace"]
        else
          {}
        end
      end
    end

    def marketplace_secrets
      @marketplace_secrets ||= begin
        secrets_file = "/etc/chef-marketplace/chef-marketplace-secrets.json"
        if ::File.exist?(secrets_file)
          Chef::JSONCompat.from_json(::File.read(secrets_file))
        else
          {}
        end
      end
    end

    def role
      if marketplace_config.key?("role")
        marketplace_config["role"]
      else
        msg = "Could not determine the Chef Marketplace role.\n"
        msg << "Please set the role in /etc/chef-marketplace/marketplace.rb\n"
        msg << "and run 'chef-marketplace-ctl reconfigure'."
        log(msg, :error)
        exit(1)
      end
    end

    def fqdn
      marketplace_config["api_fqdn"]
    end

    def ssl_port_for(service)
      case service.to_sym
      when :compliance
        marketplace_config["compliance"]["ssl_port"]
      when :analytics
        marketplace_config["analytics"]["ssl_port"]
      when :server
        marketplace_config["api_ssl_port"]
      else
        raise "Unknown service: #{service}"
      end
    end

    def restart_reckoner
      retry_command("chef-marketplace-ctl restart reckoner", retries: 2)
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
        log("You must agree to the Chef Software, Inc License Agreement in order to continue.", :error)
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
        "chef-marketplace-ctl register-node",
        "-f #{options.first_name.to_s.shellescape}",
        "-l #{options.last_name.to_s.shellescape}",
        "-e #{options.email.to_s.shellescape}",
        "-o #{options.organization.to_s.shellescape}",
      ].join(" ")

      retry_command(cmd, retries: 2, seconds: 10)
    end

    def reconfigure(product)
      case product.to_s
      when "marketplace"
        service_name = "Chef Marketplace"
        ctl_command = "chef-marketplace-ctl"
      when "server"
        service_name = "Chef Server"
        ctl_command = "chef-server-ctl"
      when "manage"
        service_name = "Chef Manage"
        ctl_command = "chef-manage-ctl"
      when "reporting"
        service_name = "Chef Reporting"
        ctl_command = "opscode-reporting-ctl"
      when "analytics"
        service_name = "Chef Analytics"
        ctl_command = "opscode-analytics-ctl"
      when "compliance"
        service_name = "Chef Compliance"
        ctl_command = "chef-compliance-ctl"
      when "delivery"
        service_name = "Chef Automate"
        ctl_command = "delivery-ctl"
      else
        raise "Unknown product: #{product}"
      end

      log "Please wait while we set up #{service_name}. This may take a few minutes to complete..."

      # As of 12/29/15 opscode-analytics and opscode-reporting both don't set
      # up these environment variables during the reconfigure chef-client runs.
      # Failing to do so isn't usually a problem because reconfiguring is usually
      # done by a user whose shell environment is passed through.  However, when
      # the command is run by a system user lacking such variables (rc/cloud-init),
      # the reconfigure will fail because rabbitmqctl needs them to be set.
      # Until both packages have been fixed this is our workaround.
      retry_command("#{ctl_command} reconfigure", retries: 2, seconds: 4, env: { "HOME" => "/root", "USER" => "root" })
    end

    def run_analytics_preflight_check
      unless run_command("opscode-analytics preflight-check").success?
        log("Chef Analtyics preflight check failed, cannot set up Chef Analytics", :error)
        exit 1
      end
    end

    def update_software
      log "Updating the Chef Server software packages..."
      run_command("chef-marketplace-ctl upgrade -y")
    end

    def create_server_user
      cmd = [
        "chef-server-ctl user-create",
        options.username.to_s.shellescape,
        options.first_name.to_s.shellescape,
        options.last_name.to_s.shellescape,
        options.email.to_s.shellescape,
        options.password.to_s.shellescape,
      ].join(" ")

      retry_command(cmd, retries: 1)
    end

    def create_server_org
      cmd = [
        "chef-server-ctl org-create",
        options.organization.to_s.shellescape,
        options.organization.to_s.shellescape,
        "-a",
        options.username.to_s.shellescape,
      ].join(" ")

      retry_command(cmd, retries: 1)
    end

    def retry_command(cmd, retries: 5, seconds: 2, env: {})
      retries.times do
        command = Mixlib::ShellOut.new(cmd)
        command.environment = env unless env.empty?
        command.live_stream = STDOUT if options.debug
        command.run_command
        return unless command.error?
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

      log("Please wait for software configuration. This may take a few minutes to complete..")
      Timeout.timeout(1800) do
        sleep 5 while cloud_init_running?
      end
    rescue Timeout::Error
      log("Timed out waiting for background configuration to complete", :error)
      exit(1)
    end

    def preconfigured?
      File.exist?("/var/opt/chef-marketplace/preconfigured")
    end

    def cloud_init_running?
      File.exist?("/var/opt/chef-marketplace/cloud_init_running")
    end

    def redirect_user
      msg = ["\n\nYou're all set!\n"]

      case role
      when "server", "aio"
        msg << ["Next you'll want to log into the Chef management console and download the Starter Kit:",
                "https://#{fqdn}:#{ssl_port_for(:server)}/organizations/#{options.organization}/getting_started\n",
                "Use your username '#{options.username}' instead of your email address to login\n",
               ]
      when "compliance"
        msg << ["Next you'll want to log into the Chef Compliance Web UI",
                "https://#{fqdn}:#{ssl_port_for(:compliance)}/#/setup\n",
               ]
      when "analytics"
        msg << ["Next you'll want to log into the Chef Analytics Web UI",
                "https://#{fqdn}\n",

                "Use your Chef Server username instead of your email address to login\n",
               ]
      end

      msg << "In order to use Transport Layer Security (TLS) we had to generate a self-signed certificate which"
      msg << "might cause a warning in your browser, you can safely ignore it.\n"

      if role == "aio"
        msg << "\nGain insight into your infrastructure in the Chef Analytics UI:\n"
        msg << "https://#{fqdn}:#{ssl_port_for(:analytics)}\n\n"
      end

      log(msg.flatten.join("\n"))
    end
  end
end
