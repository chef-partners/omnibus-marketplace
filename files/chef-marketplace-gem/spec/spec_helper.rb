require 'rspec'
require 'highline'
require 'pathname'
require 'marketplace/helpers'

def with_user_input(string = '')
  stdin = StringIO.new
  stdout = StringIO.new
  stdin << string
  stdin << "\n"
  stdin.rewind
  allow(subject).to receive(:ui).and_return(HighLine.new(stdin, stdout))
  yield(stdin, stdout) if block_given?
end

shared_examples_for 'a standard metric collector' do
  describe '.data' do
    let(:instance) { double('instance') }

    it 'creates a new instance and collects/returns data' do
      expect(described_class).to receive(:new).and_return(instance)
      expect(instance).to receive(:collect).and_return('collected_data')
      expect(described_class.data).to eq('collected_data')
    end
  end
end

shared_examples_for 'a logparser metric collector' do
  describe '#filenames' do
    it 'does not raise an exception' do
      expect { described_class.new.filenames }.not_to raise_error
    end
  end

  describe '#metric_matchers' do
    it 'does not raise an exception' do
      expect { described_class.new.metric_matchers }.not_to raise_error
    end
  end
end