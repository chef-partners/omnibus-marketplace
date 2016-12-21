module Biscotti
  module Routes
    class Base < Sinatra::Application
      configure do
        register Sinatra::Flash
        helpers Sinatra::Streaming

        set :views, "app/views"
        set :root, File.expand_path("../../../", __FILE__)
        set :show_exceptions, :after_handler if development?
      end
    end
  end
end
