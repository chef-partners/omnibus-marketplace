module Biscotti
  module Extensions
    module StarterKitDSL
      module_function

      module Helpers
        def create_key_pair
          if !params["pubkey"].empty?
            [params["pubkey"], nil]
          else
            key = OpenSSL::PKey::RSA.new(2048)
            [key.public_key.to_pem, key.to_pem]
          end
        end

        def setup_chef_server(args)
          chef_server = Biscotti::ChefServerSetup.new(
            organization: params["organization"].downcase,
            username: params["username"].downcase,
            last_name: params["lastname"],
            first_name: params["firstname"],
            email: params["email"].downcase,
            password: params["password"],
            **args
          )
          validator_key = chef_server.create_org
          chef_server.create_user
          chef_server.associate_user
          validator_key
        end

        def setup_chef_automate(args)
          chef_automate = Biscotti::ChefAutomateSetup.new(
            admin_password: Biscotti::App.settings.automate["credentials"]["admin_password"],
            first_name: params["firstname"],
            last_name: params["lastname"],
            username: params["username"].downcase,
            email: params["email"].downcase,
            password: params["password"],
            **args
          )
          chef_automate.create_user
          chef_automate.set_user_password
          chef_automate.set_user_privileges
        end

        def create_starter_kit(args)
          Biscotti::StarterKit.new(
            admin_password: Biscotti::App.settings.automate["credentials"]["admin_password"],
            builder_password: Biscotti::App.settings.automate["credentials"]["builder_password"],
            frontend_url: Biscotti::App.settings.frontend_url,
            organization: params["organization"].downcase,
            username: params["username"].downcase,
            last_name: params["lastname"],
            first_name: params["firstname"],
            email: params["email"].downcase,
            password: params["password"],
            **args
          )
        end

        def register_node
          Biscotti::NodeRegistration.new(
            platform: Biscotti::App.settings.platform,
            platform_uuid: Biscotti::App.settings.biscotti["uuid"],
            license: "flexible",
            role: "automate",
            last_name: params["lastname"],
            first_name: params["firstname"],
            email: params["email"].downcase,
            organization: params["organization"].downcase
          ).register if params["supportaccount"]
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
