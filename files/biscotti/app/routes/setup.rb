module Biscotti
  module Routes
    class Setup < Biscotti::Routes::Base
      register Biscotti::Extensions::SetupDSL

      get "/setup" do
        erb :setup
      end

      post "/setup/starter-kit" do
        response.headers["content-type"] = "application/zip"
        attachment(starter_kit.filename)
        starter_kit.tgz.read
      end
    end
  end
end
