require 'chef/server_api'

class Marketplace
  class Reckoner
    class Checker
      class ChefServer
        attr_accessor :api

        def initialize(opts = {})
          init(opts)
        end

        def current_usage
          api.get('license')['node_count']
        end

        def max_nodes
          api.get('license')['node_license']
        end

        def limit_exceeded?
          api.get('license')['limit_exceeded']
        end

        def reset!
          @api = nil
          init
        end

        private

        def init(opts = {})
          @api = Chef::ServerAPI.new(
            opts[:endpoint] || Marketplace::Reckoner::Config['server']['endpoint'],
            client_name: opts[:client] || Marketplace::Reckoner::Config['server']['client'],
            signing_key_filename: opts[:client_key_path] || Marketplace::Reckoner::Config['server']['client_key_path']
          )
          Chef::Config['ssl_verify_mode'] = :verify_none
        end
      end
    end
  end
end
