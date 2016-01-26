require 'resolv'
require 'net/http'
require 'timeout'

class Marketplace
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

    def outbound_traffic_disabled?
      node['chef-marketplace']['disable_outbound_traffic']
    end

    def security_enabled?
      node['chef-marketplace'].attribute?('security') && node['chef-marketplace']['security']['enabled']
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

    def reckoner_enabled?
      node['chef-marketplace']['license']['type'] == 'flexible' || node['chef-marketplace']['reckoner']['enabled']
    rescue NoMethodError
      false
    end

    def set_reckoner_usage_dimension
      if node['chef-marketplace']['role'] =~ /aio|server/
        node.set['chef-marketplace']['reckoner']['usage_dimension'] = 'ChefNodes'
      elsif node['chef-marketplace']['role'] == 'compliance'
        node.set['chef-marketplace']['reckoner']['usage_dimension'] = 'ComplianceNodes'
      end
    end

    def manage_url
      "https://#{node['chef-marketplace']['api_fqdn']}"
    end

    def analytics_url
      "#{manage_url}:#{node['chef-marketplace']['analytics']['ssl_port']}"
    end

    def motd_variables
      vars = {
        doc_url: node['chef-marketplace']['documentation']['url'],
        support_email: node['chef-marketplace']['support']['email']
      }

      case node['chef-marketplace']['role']
      when 'server', 'aio'
        vars[:role_name] = 'Chef Server'
        unless security_enabled?
          vars[:analytics_href] = analytics_url
          vars[:manage_url] = manage_url
        end
      when 'analytics'
        vars[:role_name] = 'Chef Analytics'
        vars[:analytics_href] = manage_url unless security_enabled?
      when 'compliance'
        vars[:role_name] = 'Chef Compliance'
        vars[:compliance_url] = "#{manage_url}/#/setup" unless security_enabled?
      end

      vars
    end

    # Returns an array of hashes of which omnibus commands should be enabled/disabled
    def omnibus_commands
      service_dir = '/opt/chef-marketplace/embedded/service'

      enabled_commands = %w(
        setup.rb
        hostname.rb
        test.rb
        upgrade.rb
        trim_actions_db.rb
        register_node.rb
        prepare_for_publishing.rb
      )
      disabled_commands = []

      case node['chef-marketplace']['role']
      when 'server', 'compliance'
        disabled_commands << enabled_commands.delete('trim_actions_db.rb')
      when 'aio', 'analytics'
        # Keep em all
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
            node['cloud_v2']['public_hostname'] ? "#{node['cloud_v2']['public_hostname']}.cloudapp.net" : node['fqdn']
          else # aws, etc..
            node['cloud_v2']['public_hostname'] || node['cloud_v2']['local_hostname'] || node['fqdn']
          end
        else
          node['fqdn']
        end
    end

    def analytics_state_files
      %w(
        /var/opt/opscode-analytics/bootstrapped
        /var/opt/opscode-analytics/actions/config/secrets.yml
        /var/opt/opscode-analytics/actions/config/database.yml
        /var/opt/opscode-analytics/actions-messages/sys.config
        /var/opt/opscode-analytics/notifier/sys.config
        /var/opt/opscode-analytics/notifier_config/sys.config
        /var/opt/opscode-analytics/storm/topology/alaska/alaska.conf
        /var/opt/opscode-analytics/storm/topology/alaska/truststore.jks
        /var/opt/opscode/nginx/etc/nginx.d/analytics.conf
        /etc/opscode-analytics/actions-source.json
        /etc/opscode-analytics/alaska-tools.rb
        /etc/opscode-analytics/opscode-analytics-running.json
        /etc/opscode-analytics/opscode-analytics-secrets.json
        /etc/opscode-analytics/webui_priv.pem
        /opt/opscode-analytics/embedded/service/actions_messages/sys.config
        /opt/opscode-analytics/embedded/service/actions/config/initializers/assets.rb
        /opt/opscode-analytics/embedded/service/notifier/sys.config
        /opt/opscode-analytics/embedded/service/notifier_config/sys.config
        /opt/opscode-analytics/embedded/bin/storm
        /opt/opscode-analytics/embedded/bin/alaska
      )
    end

    def analytics_state_directories
      %w(
        /opt/opscode-analytics/sv
        /opt/opscode-analytics/init
        /opt/opscode-analytics/service
        /var/opt/opscode-analytics/postgresql
        /var/opt/opscode-analytics/ssl
        /var/opt/opscode-analytics/zookeeper/data
      )
    end

    def server_state_files
      %w(
        /etc/opscode/webui_pub.pem
        /etc/opscode/worker-public.pem
        /etc/opscode/chef-server-running.json
        /etc/opscode/pivotal.pem
        /etc/opscode/private-chef-secrets.json
        /etc/opscode/webui_priv.pem
        /etc/opscode/worker-private.pem
        /etc/opscode-reporting/opscode-reporting-running.json
        /etc/opscode-reporting/opscode-reporting-secrets.json
        /etc/chef-manage/secrets.rb
        /opt/opscode/embedded/service/oc_bifrost/sys.config
        /opt/opscode/embedded/service/oc_id/config/settings/production.yml
        /opt/opscode/embedded/service/oc_id/config/initializers/secret_token.rb
        /opt/opscode/embedded/service/oc_id/config/database.yml
        /opt/opscode/embedded/service/opscode-solr4/jetty/etc/jetty.xml
        /opt/opscode/embedded/service/opscode-solr4/jetty/contexts/solr-jetty-context.xml
        /opt/opscode/embedded/service/opscode-erchef/sys.config
        /opt/opscode/embedded/service/bookshelf/sys.config
        /opt/opscode/embedded/service/chef-server-bootstrap/bootstrapper-config/pivotal.yml
        /opt/opscode/embedded/service/opscode-chef-mover/sys.config
        /opt/opscode-reporting/embedded/service/opscode-reporting/db/permissions.sql
        /opt/opscode-reporting/embedded/service/opscode-reporting/etc/sys.config
        /opt/chef-manage/embedded/service/chef-manage/config/settings/production.yml
        /opt/chef-manage/embedded/service/chef-manage/config/newrelic.yml
        /var/opt/opscode/bootstrapped
        /var/opt/opscode/bookshelf/sys.config
        /var/opt/opscode/oc_bifrost/sys.config
        /var/opt/opscode/opscode-account-mover/sys.config
        /var/opt/opscode/opscode-erchef/sys.config
        /var/opt/opscode-reporting/bootstrapped
        /var/opt/opscode-reporting/etc/sys.config
        /var/opt/chef-manage/etc/chef-manage-running.json
        /var/opt/chef-manage/etc/settings.yml
      )
    end

    def server_state_directories
      %w(
        /opt/opscode/sv
        /opt/opscode/service
        /opt/opscode/init
        /opt/chef-manage/sv
        /opt/chef-manage/init
        /opt/chef-manage/service
        /var/opt/opscode/nginx/ca
        /var/opt/opscode/nginx/scripts
        /var/opt/opscode/pc_id/config
        /var/opt/opscode/opscode-account-mover/data
        /var/opt/opscode/opscode-expander/etc
        /var/opt/opscode/opscode-solr4
        /var/opt/opscode/postgresql
        /var/opt/opscode/rabbitmq
        /var/opt/opscode/redis_lb
        /var/opt/opscode/upgrades
        /var/opt/opscode/local-mode-cache
      )
    end

    def compliance_state_files
      %w(
        /etc/chef-compliance/chef-compliance-running.json
        /etc/chef-compliance/chef-compliance-secrets.json
        /etc/chef-compliance/server-config.json
      )
    end

    def compliance_state_directories
      %w(
        /opt/chef-compliance/sv
        /opt/chef-compliance/init
        /opt/chef-compliance/service
        /var/opt/chef-compliance/postgresql
        /var/opt/chef-compliance/ssl
      )
    end
  end
end

if defined?(Chef)
  Chef::Recipe.send(:include, Marketplace::Helpers)
  Chef::Provider.send(:include, Marketplace::Helpers)
  Chef::Resource.send(:include, Marketplace::Helpers)
  Chef::ResourceDefinition.send(:include, Marketplace::Helpers)
end
