require 'rspec'
require 'highline'
require 'omnibus-ctl'
require 'pathname'

def with_user_input(string = '')
  stdin = StringIO.new
  stdout = StringIO.new
  stdin << string
  stdin << ("\n")
  stdin.rewind
  allow(subject).to receive(:highline).and_return(HighLine.new(stdin, stdout))
  yield(stdin, stdout) if block_given?
end

class OmnibusCtlTest
  attr_accessor :plugin, :name

  def initialize(plugin_name)
    @name = plugin_name
    path = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "../#{name}.rb")))
    fail "Could not find plugin at #{path.expand_path}" unless path.exist?
    @plugin = Omnibus::Ctl.new(path.basename.sub_ext('').to_s)
    plugin.load_file(path.expand_path.to_s)
  end

  def execute(command_with_args)
    # Add useless fake PATHS to ARGV
    ARGV.clear
    ARGV << '/embedded/bin/omnibus-ctl'
    ARGV << name
    ARGV << '/embedded/service/omnibus-ctl'

    # Separate command and args and add args to ARGV
    args = command_with_args.split
    command = args.shift

    args.each { |a| ARGV << a }

    plugin.run(Array(command))
  end
end
