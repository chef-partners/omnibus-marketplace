require 'rest-client'

module Biscotti
  module Extensions
    module DelivAPI
      module_function

      module Helpers
        def deliv_api
          @deliv_api ||= begin
                           deliv_root = "https://localhost/api/v0/e/default"
                           client = RestClient::Resource.new(
                             deliv_root,
                             verify_ssl: false,
                             headers:
                               {
                                 "Content-Type" => "application/json"
                               }
                           )
                           token_body = {
                             username: "admin",
                             password: Biscotti::App.settings.biscotti["credentials"]["admin_password"]
                           }.to_json
                           token_response = client["get-token"].post(token_body)
                           token = JSON.parse(token_response.body)["token"]
                           client.headers["chef-delivery-token"] = token
                           client.headers["chef-delivery-user"] = "admin"
                           client
                         end
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
