class Marketplace
  module Helpers
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
