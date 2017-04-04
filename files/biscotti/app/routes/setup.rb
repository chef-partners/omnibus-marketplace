module Biscotti
  module Routes
    class Setup < Biscotti::Routes::Base
      register Biscotti::Extensions::StarterKitDSL

      get "/setup" do
        @biscotti_settings = Biscotti::App.settings.biscotti
        erb :setup
      end

      post "/setup/starter-kit" do
        public_key, private_key = create_key_pair
        validator_key = setup_chef_server(public_key: public_key)
        setup_chef_automate(public_key: public_key)
        register_node
        starter_kit = create_starter_kit(
          validator_key: validator_key,
          private_key: private_key
        )
        response.headers["content-type"] = "application/zip"
        attachment(starter_kit.filename)
        starter_kit.zip
      end
    end
  end
end
