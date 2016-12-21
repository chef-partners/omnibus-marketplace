require "rubygems"

module Biscotti
  module Helpers
    def config_file_path
      ENV["RACK_ENV"] == "production" ? "config/config.yml" : "config/#{ENV["RACK_ENV"]}-config.yml"
    end
    module_function :config_file_path
  end
end
