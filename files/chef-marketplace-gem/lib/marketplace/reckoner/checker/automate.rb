require "elasticsearch"

class Marketplace
  class Reckoner
    class Checker
      class Automate
        attr_accessor :es

        def initialize(opts = {})
          @es = Elasticsearch::Client.new(
            url: opts[:url] || Marketplace::Reckoner::Config["elasticsearch"]["url"],
            transport_options: {
              ssl: {
                verify: false,
              },
            }
          )
        end

        def current_usage
          count = 0

          # Limit our result set to 100 nodes and allow the scrolling identifier
          # to exist for 5 minutes.
          result = es.search(
            index: "node-state",
            scroll: "5m",
            search_type: "scan",
            size: "100",
            body: {
              query: {
                filtered: {
                  filter: { term: { exists: "true" } },
                },
              },
              _source: %w{checkin},
            }
          )

          # Iterate over our our search collection and count the active nodes
          loop do
            result = es.scroll(scroll_id: result["_scroll_id"], scroll: "5m")
            break if !result || result["hits"]["hits"].empty?
            count += result["hits"]["hits"].count
          end

          count
        end
      end
    end
  end
end