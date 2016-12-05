require "zlib"
require "rubygems"
require "rubygems/package"

module Biscotti
  class StarterKit
    attr_accessor :credentials, :params

    def initialize(credentials: {}, params: {})
      @credentials = credentials
      @params = validate_and_normalize_params(params)
    end

    def tgz
      @tgz ||=
        begin
          tarball = StringIO.new
          archive = StringIO.new
          Gem::Package::TarWriter.new(tarball) do |tar|
            tar.mkdir(".chef", 0755)
            tar.add_file(knife_config_filename, 0755) { knife_config }
            tar.add_file(automate_admin_creds_filename, 0600) { automate_admin_creds }
            tar.add_file(pivotal_key_filename, 0600) { pivotal_key }
            if create_private_key?
              tar.add_file(private_key_filename, 0755) { private_key }
            end
            tar.mkdir(".chef/trusted_certs", 0755)
            # TODO add the ssl certs
          end
          tarball.rewind
          gz = Zlib::GzipWriter.new(archive)
          gz.write(tarball.string)
          gz.close # close to write the gzip footer
          StringIO.new(archive.string)
        end
    end

    def filename
      "starter_kit.tgz"
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
