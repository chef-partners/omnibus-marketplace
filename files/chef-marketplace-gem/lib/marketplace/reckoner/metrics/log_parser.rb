require 'marketplace/reckoner/metrics/base'

class Marketplace::Reckoner::Metrics
  class LogParser < Base
    attr_accessor :counts
    def initialize
      super

      @counts = metric_matchers.keys.each_with_object({}) do |metric, memo|
                  memo[metric] = 0
                end
    end

    def collect
      Array(filenames).each do |filename|
        next unless File.exist?(filename)

        File.open(filename, "r") do |file|
          until file.eof?
            line = file.readline.strip
            metric_matchers.each do |metric, block|
              counts[metric] += 1 if block.call(line)
            end
          end
        end
      end

      counts
    end

    def filenames
      raise "No filenames defined in #{self.class}."
    end

    def metric_matchers
      raise "No metric_matchers defined in #{self.class}."
    end
  end
end
