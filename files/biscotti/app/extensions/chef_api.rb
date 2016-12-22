require 'chef/rest'

# TODO: set this somewhere else or fix the ssl
Chef::Config[:ssl_verify_mode] = :verify_none

module Biscotti
  module Extensions
    module ChefAPI
      module_function

      Chef::REST::RESTRequest.user_agent = "Chef Biscotti#{Chef::REST::RESTRequest::UA_COMMON}"

      module Helpers
        def chef_api
          @chef_api ||= Chef::REST.new('https://localhost/',
                                       'pivotal',
                                       '/etc/opscode/pivotal.pem')
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
