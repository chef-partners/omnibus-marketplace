require 'marketplace/reckoner/config'
require 'marketplace/reckoner/checker'
require 'marketplace/reckoner/updater'

# The Reckoner checks node usage and updates flexible billing endpoints
class Marketplace
  class Reckoner
    def self.update_usage
      new.update_usage
    end

    attr_accessor :opts, :usage_checker, :usage_updater

    def initialize(opts = {})
      @opts = opts
      @usage_checker = Marketplace::Reckoner::Checker.from_opts(opts)
      @usage_updater = Marketplace::Reckoner::Updater.from_opts(opts)
    end

    def update_usage
      usage_updater.update(usage_checker.current_usage)
    end
  end
end
