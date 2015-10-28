require 'resolv'
require 'net/http'
require 'timeout'

module Marketplace
  module Helpers
    def motd_action
      node['chef-marketplace']['motd']['enabled'] ? :create : :delete
    end

    def reporting_partition_action
      node['chef-marketplace']['reporting']['cron']['enabled'] ? :create : :delete
    end

    def actions_trimmer_action
      node['chef-marketplace']['analytics']['trimmer']['enabled'] ? :create : :delete
    end

    def current_user_directories
      Etc::Passwd.each_with_object({}) do |user, memo|
        next if %w(halt sync shutdown).include?(user.name) ||
                user.shell =~ %r{(/sbin/nologin|/bin/false)}
        memo[user.name] = user.dir
      end
    end

    def system_ssh_keys
      %w(key key.pub dsa_key dsa_key.pub rsa_key.pub rsa_key).map do |key|
        "/etc/ssh/ssh_host_#{key}"
      end
    end

    def current_sudoers
      Dir['/etc/sudoers.d/*']
    end

    def gecos
      case node['chef-marketplace']['platform']
      when 'aws' then 'Ec2 User'
      when 'openstack' then 'OpenStack User'
      when 'oracle' then 'Oracle User'
      end
    end

    def cron_package
      case node['platform']
      when 'redhat', 'centos', 'oracle' then 'cronie'
      when 'debian', 'ubuntu' then 'cron'
      end
    end

    def default_package_mirror_uri
      case node['platform']
      when 'redhat' then 'http://mirrorlist.centos.org'
      when 'centos' then 'http://mirrorlist.centos.org'
      when 'ubuntu' then 'http://us.archive.ubuntu.com/ubuntu/'
      end
    end

    # When the Chef Server is in a private VPC some recipes will wait for a very
    # long time for yum to timeout and then eventually crash. Instead, we won't
    # worry about package installs/removals in that environment.
    def mirrors_reachable?(mirror = nil)
      mirror ||= default_package_mirror_uri
      return node['chef-marketplace']['mirrors_reachable'] if node['chef-marketplace'].attribute?('mirrors_reachable')

      # check whether or not outbound traffic is disabled
      if node['chef-marketplace']['disable_outbound_traffic']
        return node.set['chef-marketplace']['mirrors_reachable'] = false
      end

      # check if the hostname is resolvable
      uri = URI(mirror)
      Resolv.getaddress(uri.host)

      # check if the mirror is reachable
      Timeout.timeout(2) do
        res = Net::HTTP.get_response(uri)
        node.set['chef-marketplace']['mirrors_reachable'] = res.is_a?(Net::HTTPSuccess)
      end

      node['chef-marketplace']['mirrors_reachable']
    rescue
      node.set['chef-marketplace']['mirrors_reachable'] = false
    end

    # We only want to run the security in two scenarios:
    #   1) Security is explicitly enabled
    #   2) We're publishing for the first time
    #
    # We do this because the security recipe will blow away the SSH keys.
    def security_enabled?
      if node['chef-marketplace'].attribute?('security') && node['chef-marketplace']['security']['enabled']
        true
      elsif previously_published?
        false
      elsif publishing_enabled?
        true
      else
        false
      end
    end

    def publishing_enabled?
      node['chef-marketplace']['publishing']['enabled']
    rescue NoMethodError
      false
    end

    def previously_published?
      node.attribute?('previous_run') && node['previous_run'].attribute?('publishing') && node['previous_run']['publishing']['enabled']
    end

    def chef_server_configured?
      File.exist?('/etc/opscode/chef-server-running.json')
    end

    def analytics_configured?
      File.exist?('/etc/opscode-analytics/opscode-analytics-running.json')
    end

    def compliance_configured?
      File.exist?('/etc/chef-compliance/chef-compliance-running.json')
    end

    def manage_url
      "https://#{node['chef-marketplace']['api_fqdn']}"
    end

    def analytics_url
      "#{manage_url}:#{node['chef-marketplace']['analytics']['ssl_port']}"
    end

    def motd_variables
      role = node['chef-marketplace']['role']
      case role
      when 'server', 'aio'
        role_name = 'Chef Server'
        analytics_href = analytics_url
      when 'analytics'
        role_name = 'Chef Analytics'
        analytics_href = manage_url
      when 'compliance'
        role_name = 'Chef Compliance'
      end

      vars = {
        role_name: role_name,
        support_email: node['chef-marketplace']['support']['email'],
        doc_url: node['chef-marketplace']['documentation']['url']
      }

      vars.merge!(
        compliance_url: role == 'compliance' ? manage_url : false,
        manage_url: role =~ /aio|server/ ? manage_url : false,
        analytics_url: role =~ /aio|analytics/ ? analytics_href : false
      ) unless security_enabled?

      vars
    end

    # Returns a hash of which omnibus commands should be enabled/disabled
    def omnibus_commands
      service_dir = '/opt/chef-marketplace/embedded/service'

      case node['chef-marketplace']['role']
      when 'server', 'compliance'
        enabled_commands = %w(setup.rb hostname.rb test.rb upgrade.rb)
        disabled_commands = %w(trim_actions_db.rb)
      when 'aio', 'analytics'
        enabled_commands = %w(setup.rb hostname.rb test.rb upgrade.rb trim_actions_db.rb)
        disabled_commands = []
      end

      enabled_commands.map! do |cmd|
        { source: "#{service_dir}/chef-marketplace-ctl/#{cmd}",
          destination: "#{service_dir}/omnibus-ctl/#{cmd}",
          action: :create
        }
      end

      disabled_commands.map! do |cmd|
        { source: "#{service_dir}/chef-marketplace-ctl/#{cmd}",
          destination: "#{service_dir}/omnibus-ctl/#{cmd}",
          action: :delete
        }
      end

      enabled_commands + disabled_commands
    end

    def determine_api_fqdn
      # 1) Use the value set in marketplace.rb
      # 2) Use the cloud public hostname
      # 3) Use the cloud local hostname
      # 4) Fallback on the FQDN
      node.set['chef-marketplace']['api_fqdn'] =
        if node['chef-marketplace']['api_fqdn']
          node['chef-marketplace']['api_fqdn']
        elsif node.key?('cloud_v2') && !node['cloud_v2'].nil?
          case node['cloud_v2']['provider']
          when 'gce'
            node['cloud_v2']['public_ipv4']
          when 'azure'
            "#{node['cloud_v2']['public_hostname']}.cloudapp.net"
          else # aws, etc..
            node['cloud_v2']['public_hostname'] || node['cloud_v2']['local_hostname'] || node['fqdn']
          end
        else
          node['fqdn']
        end
    end
  end
end

if defined?(Chef)
  Chef::Recipe.send(:include, Marketplace::Helpers)
  Chef::Provider.send(:include, Marketplace::Helpers)
  Chef::Resource.send(:include, Marketplace::Helpers)
  Chef::ResourceDefinition.send(:include, Marketplace::Helpers)
end
