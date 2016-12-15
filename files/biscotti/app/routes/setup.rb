module Biscotti
  module Routes
    class Setup < Biscotti::Routes::Base
      register Biscotti::Extensions::SetupDSL
      register Biscotti::Extensions::ChefAPI
      register Biscotti::Extensions::DelivAPI

      get "/setup" do
        erb :setup
      end

      post "/setup/starter-kit" do
        response.headers["content-type"] = "application/zip"

        private_key, validator = do_setup(params)

        attachment(starter_kit.filename)
        starter_kit.zip
      end

      def do_setup(params)
        private_key = ensure_public_key(params)
        validator_key = create_chef_organization(params)
        create_chef_user(params)
        create_chef_user_key(params)
        associate_chef_user(params)

        # TODO: make chef user a server-admin
        # this is blocked on having server-admins being given
        # full pivotal-level permissions. the start of this
        # work is currently being done in
        # https://github.com/chef/chef-server/pull/886

        create_automate_user(params)
        create_automate_org(params)
        create_support_account(params)
        [private_key, validator_key]
      end

      def ensure_public_key(params)
        return nil if params["pubkey"] and not params["pubkey"].empty?

        private_key = OpenSSL::PKey::RSA.new(2048)
        params["pubkey"] = private_key.public_key.to_pem
        private_key.to_pem
      end

      def create_chef_organization(params)
        org_body = {
          name: short_orgname(params),
          full_name: params["organization"]
        }

        response = chef_api.post_rest("/organizations", org_body)
        response["private_key"]
      end

      def create_chef_user(params)
        user_body = {
          username: params["username"],
          first_name: params["firstname"],
          last_name: params["lastname"],
          display_name: "#{params["firstname"]} #{params["lastname"]}",
          email: params["email"],
          password: params["password"]
        }

        response = chef_api.post_rest("/users", user_body)
      end

      def create_chef_user_key(params)
        key_body = {
          name: "default",
          public_key: params["pubkey"],
          expiration_date: "infinity"
        }

        response = chef_api.post_rest("/users/#{params["username"]}/keys", key_body)
      end

      def associate_chef_user(params)
        assoc_body = { user: params["username"] }
        assoc_resp = chef_api.post_rest("/organizations/#{short_orgname(params)}/association_requests", assoc_body)
        assoc_id = assoc_resp["uri"].split("/").last
        accept_body = { response: "accept" }
        chef_api.put_rest("users/#{params["username"]}/association_requests/#{assoc_id}", accept_body)
      end

      def create_automate_user(params)
        user_body = {
          name: params["username"],
          first: params["firstname"],
          last: params["lastname"],
          email: params["email"],
          ssh_pub_key: params["pubkey"]
        }.to_json
        deliv_api["internal-users"].post(user_body)

        pass_body = {
          password: params["password"]
        }.to_json
        deliv_api["internal-users/#{params["username"]}/reset-password"].post(pass_body)

        roles_body = {
          set: ["admin"]
        }.to_json
        deliv_api["authz/users/#{params["username"]}"].post(roles_body)
      end

      def create_automate_org(params)
        # TODO
      end

      def create_support_account(params)

      end

      def short_orgname(params)
        params["organization"].downcase.gsub(/\s+/, "_")
      end
    end
  end
end
