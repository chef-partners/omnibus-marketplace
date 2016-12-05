module Biscotti
  module Routes
    class Index < Biscotti::Routes::Base
      register Extensions::BakeryDSL

      get "/" do
        @biscotti = Biscotti::App.settings.biscotti
        erb :index
      end

      error do
        redirect "/"
      end

      post "/?" do
        if valid_uuid?
          bake_cookie
          redirect Biscotti::App.settings.biscotti["redirect_path"]
        else
          flash[:error] = "The #{settings.biscotti["uuid_type"]} that you supplied " \
            "did not match.  Please verify and try again."
          redirect "/"
        end
      end
    end
  end
end
