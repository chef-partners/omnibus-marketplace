require 'ostruct'
require 'highline/import'
# Hacks to get around using helpers with omnibus-ctl
begin
  require 'helpers'
rescue LoadError
  require '/opt/chef-marketplace/embedded/service/omnibus-ctl/marketplace/helpers'
end

class Marketplace
  class Options
    include Marketplace::Helpers

    attr_accessor :options

    #
    # @param [OpenStruct] options
    #
    def initialize(options)
      @options = options
      @highline = HighLine.new
      @required_options = %w(first_name last_name username email organization password).freeze
    end

    def validate
      required_options.each do |opt|
        next if options.send(opt)
        options[opt] =
          case opt
          when 'password'
            highline.ask('<%= @key %>: ') do |q|
              q.echo = '*'
              q.validate = ->(p) { p.length >= 6 }
              q.verify_match = true
              q.gather = {
                'Please enter a password' => '',
                'Please enter it again for verification' => ''
              }
              q.responses[:not_valid] = 'Password must be at least 6 characters'
            end
          when 'organization'
            highline.ask('Please enter the name of your Organization (e.g. Chef):', ->(org) { normalize_option(org) }) do |q|
              q.validate = ->(o) { o =~ /[a-z0-9\-_]+/ && o.length >= 1 && o.length <= 255 }
              q.responses[:not_valid] = 'The Organization name must begin with a lower-case letter or digit, may only contain lower-case letters, digits, hyphens, and underscores, and must be between 1 and 255 characters.  Please enter a valid Organization name'
            end
          when 'email'
            highline.ask('Please enter your email:', ->(org) { normalize_email(org) }) do |q|
              q.validate = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
              q.responses[:not_valid] = 'Your entry was not a valid email address'
            end
          else
            highline.ask("Please enter your #{opt}:", ->(org) { normalize_option(org) })
          end
      end
    end

    # Forward everything to the options OpenStruct first
    def method_missing(meth, *args, &block)
      options.respond_to?(meth) ? options.send(meth, *args, &block) : super
    end

    private

    attr_reader :required_options
    attr_accessor :highline
  end
end
