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
      end
    end

    # When the Chef Server is in a private VPC some recipes will wait for a very
    # long time for yum to timeout and then eventually crash. Instead, we won't
    # worry about package installs/removals in that environment.
    def mirrors_reachable?(mirror = 'http://mirrorlist.centos.org')
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

    def manage_url
      "https://#{node['chef-marketplace']['api_fqdn']}"
    end

    def analytics_url
      "#{manage_url}:#{node['chef-marketplace']['analytics']['ssl_port']}"
    end

    def motd_variables
      vars = {
        role: node['chef-marketplace']['role'],
        support_email: node['chef-marketplace']['support']['email'],
        doc_url: node['chef-marketplace']['documentation']['url']
      }

      vars.merge!(
        manage_url: manage_url,
        analytics_url: node['chef-marketplace']['role'] == 'aio' ? analytics_url : false
      ) unless security_enabled?

      vars
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
