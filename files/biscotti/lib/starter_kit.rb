require "zip"
require "rubygems"
require "rubygems/package"

module Biscotti
  class StarterKit
    attr_accessor :credentials, :params

    def initialize(credentials: {}, params: {})
      @credentials = credentials
      @params = validate_and_normalize_params(params)
    end

    def zip
      @zip ||=
        begin
          archive = Zip::OutputStream.new(StringIO.new, true) do |out|
            # knife config
            out.put_next_entry(knife_config_filename)
            out.write(knife_config)

            # pivotal key
            out.put_next_entry(pivotal_key_filename)
            out.write(pivotal_key)

            # chef user key
            # TODO: if exists

            # automate credentials
            out.put_next_entry(automate_admin_creds_filename)
            out.write(automate_admin_creds)

            # trusted certs
            # TODO: add certs
          end
          archive.close_buffer.string
        end
    end

    def filename
      "starter_kit.zip"
    end

    def knife_config
      StringIO.new("knife")
    end

    def knife_config_filename
      ".chef/knife.rb"
    end

    def private_key
      StringIO.new("private_key")
    end

    def private_key_filename
      ".chef/#{params["firstname"]}.pem"
    end

    def automate_admin_creds
      StringIO.new("coolcredsdawg")
    end

    def automate_admin_creds_filename
      "chef-automate-admin-credentials.txt"
    end

    def create_private_key?
      params["pubkey"].empty?
    end

    def pivotal_key
      StringIO.new("pivotal")
    end

    def pivotal_key_filename
      "pivotal.pem"
    end

    def validate_and_normalize_params(params)
      # TODO: validation and normalization :)
      params
    end

    def normalize_email(string)
      string.gsub!(/\s+/, "")
      string.downcase!
      string
    end

    def normalize_option(string)
      string = string.to_s.gsub(/::/, "/").split.join("_")
      string.tr!("-", "_")
      string.gsub!(/\W/, "")
      string.downcase!
      string
    end
  end
end
