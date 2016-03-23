require "mixlib/config"

class Marketplace
  class Reckoner
    class Config
      extend Mixlib::Config

      config_context :license do
        default :free, 0
        default :count, 0
        default :type, "fixed"
      end

      config_context :updater do
        default :enabled, true
        default :driver, "ec2"
      end

      config_context :checker do
        # chef_server or compliance
        default :driver, "chef_server"
      end

      config_context :server do
        default :endpoint, "https://localhost/"
        default :client, "pivotal"
        default :client_key_path, "/etc/opscode/pivotal.pem"
      end

      # Some DB creds for the compliance server
      config_context :db do
        default :host, "localhost"
        default :port, 3306

        configurable :user
        configurable :password
      end

      config_context :aws do
        default :usage_dimension, "ChefNodes"

        configurable :product_code
      end

      config_context :phone_home do
        default :enabled, false
        configurable :endpoint
        configurable :platform

        config_context :metrics do
          default :daily, %w{
            analytics_access_logs
            chef_node_count
            chef_nodes_per_org
            chef_org_count
            chef_user_count
            erchef_crashes
            manage_access_logs
          }
        end
      end
    end
  end
end
