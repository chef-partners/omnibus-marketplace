# frozen_string_literal: true
require "json"
require "shellwords"
require "deep_merge"

module Template
  class Parameters
    class << self
      def from_file(path)
        new(JSON.parse(File.read(File.expand_path(path)))["parameters"])
      end
    end

    def initialize(params = {})
      @params = params
    end

    def to_json
      params.to_json
    end

    def override(hash)
      params.deep_merge!(hash)
    end

    def method_missing(meth, *args, &block)
      params.send(meth, *args, &block)
    end

    private

    attr_reader :params
  end
end
