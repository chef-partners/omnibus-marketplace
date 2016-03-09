module Biscotti
  module Routes
    class Biscotti < Base
      register Extensions::BakeryDSL

      get '/biscotti' do
        @biscotti = settings.biscotti
        erb :index
      end

      post '/biscotti' do
        if valid_uuid?
          bake_cookie
          redirect '/'
        else
          flash[:error] = "The #{settings.biscotti['uuid_type']} that you supplied " \
            'did not match.  Please verify and try again.'
          redirect '/biscotti'
        end
      end
    end
  end
end