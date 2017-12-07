module Biscotti
  module Routes
    class Setup < Biscotti::Routes::Base
      register Biscotti::Extensions::StarterKitDSL
      register Biscotti::Extensions::AuthorizeDSL

      get "/setup" do
        send_file File.join(settings.public_folder, "index.html")
      end

      post "/setup/authorize" do
        handle_authorize!

        response.headers["content-type"] = "application/json"
        { "token" => hashed_token }.to_json
      end

      post "/setup/starter-kit" do
        authorize!

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
