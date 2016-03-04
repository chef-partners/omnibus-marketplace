require 'bundler'
Bundler.require

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../'))

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/flash'
require 'app/extensions'
require 'app/routes'
require 'lib/bakery'

module Biscotti
  class App < Sinatra::Base
    enable :sessions

    register Sinatra::ConfigFile
    register Sinatra::Flash

    config_file 'config/config.yml'

    set public_folder: 'assets', static: true

    use Biscotti::Routes::Biscotti
  end
end
