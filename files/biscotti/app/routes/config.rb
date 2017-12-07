module Biscotti
  module Routes
    class Config < Biscotti::Routes::Base
      get "/config" do
        config = {}
        config["message"] = Biscotti::App.settings.biscotti["message"]
        config["uuid_type"] = Biscotti::App.settings.biscotti["uuid_type"]
        config["doc_href"] = Biscotti::App.settings.biscotti["doc_href"]
        config["cloud_marketplace"] = Biscotti::App.settings.biscotti["cloud_marketplace"]
        config["auth_required"] = Biscotti::App.settings.biscotti["auth_required"]
        config.to_json
      end
    end
  end
end
