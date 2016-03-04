require 'openssl'
require 'time'

module Biscotti
  class Bakery
    attr_reader :token, :uuid, :name, :digest

    def initialize(token, uuid)
      @digest = OpenSSL::Digest.new('sha1')
      @name = 'ChefMarketplaceAuth'
      @token = token
      @uuid = uuid
    end

    def cookie
      {
        value: OpenSSL::HMAC.hexdigest(digest, token, uuid),
        domain: '',
        path: '/',
        expires: Time.now + (3600 * 24 * 31)
      }
    end
  end
end
