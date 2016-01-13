require 'mixlib/config'

class Marketplace
  class Reckoner
    class Config
      extend Mixlib::Config

      config_context :license do
        configurable :count
        configurable :free
      end

      config_context :updater do
        default :driver, 'ec2'
      end

      config_context :checker do
        # chef_server or compliance
        default :driver, 'chef_server'
      end

      config_context :server do
        default :endpoint, 'https://localhost/'
        default :client, 'pivotal'
        default :client_key_path, '/etc/opscode/pivotal.pem'
      end

      # Some DB creds for the compliance server
      config_context :db do
        default :host, 'localhost'
        default :port, 3306

        configurable :user
        configurable :password
      end

      config_context :aws do
        default :region, 'us-east-1'
        default :usage_dimension, 'ProvisionedHosts'

        configurable :product_code
      end
    end
  end
end
