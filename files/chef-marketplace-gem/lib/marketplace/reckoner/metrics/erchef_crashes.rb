require 'marketplace/reckoner/metrics/base'

class Marketplace::Reckoner::Metrics
  class ErchefCrashes < LogParser
    def filenames
      [
        '/var/log/opscode/opscode-erchef/crash.log',
        '/var/log/opscode/opscode-erchef/crash.log.0',
        '/var/log/opscode/opscode-erchef/crash.log.1'
      ]
    end

    def metric_matchers
      { log_count: proc { |line| line =~ /(CRASH|ERROR) REPORT/ } }
    end
  end
end
