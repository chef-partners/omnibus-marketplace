module Biscotti
  module Routes
    class Base < Sinatra::Application
      configure do
        register Sinatra::ConfigFile
        register Sinatra::Flash
        config_file "config/config.yml"

        set :views, "app/views"
        set :root, File.expand_path("../../../", __FILE__)
        set :show_exceptions, :after_handler
      end
    end
  end
end
