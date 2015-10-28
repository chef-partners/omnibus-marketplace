require 'rspec'
require 'highline'
require 'pathname'
require 'marketplace/helpers'

def with_user_input(string = '')
  stdin = StringIO.new
  stdout = StringIO.new
  stdin << string
  stdin << ("\n")
  stdin.rewind
  allow(subject).to receive(:ui).and_return(HighLine.new(stdin, stdout))
  yield(stdin, stdout) if block_given?
end
