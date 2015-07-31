require 'rspec'
require 'highline'

def with_user_input(string = '')
  stdin = StringIO.new
  stdout = StringIO.new
  stdin << string
  stdin << ("\n")
  stdin.rewind
  allow(subject).to receive(:highline).and_return(HighLine.new(stdin, stdout))
  yield(stdin, stdout) if block_given?
end
