$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "../"))
ENV["RACK_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

require "app/extensions"
require "app/routes"
require "lib/bakery"
require "lib/starter_kit"
require "lib/helpers"

module Biscotti
  class App < Sinatra::Base
    enable :sessions

    set public_folder: "public"

    register Sinatra::ConfigFile
    config_file Biscotti::Helpers.config_file_path

    register Sinatra::Reloader if development?
    register Sinatra::Flash

    use Biscotti::Routes::Index
    use Biscotti::Routes::Setup
  end
end
