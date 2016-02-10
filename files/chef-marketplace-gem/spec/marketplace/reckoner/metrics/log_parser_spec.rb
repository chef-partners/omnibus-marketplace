require 'spec_helper'
require 'marketplace/reckoner'

describe Marketplace::Reckoner::Metrics::LogParser do
  it_behaves_like 'a standard metric collector' 

  describe '#collect' do
    it 'parses the file and returns the metric counts' do
      parser = described_class.allocate
      file = double('file')

      expect(parser).to receive(:filenames).and_return('file1')
      expect(File).to receive(:exist?).with('file1').and_return(true)
      expect(File).to receive(:open).with('file1', 'r').and_yield(file)
      expect(file).to receive(:eof?).exactly(4).times.and_return(false, false, false, true)
      expect(file).to receive(:readline).exactly(3).times.and_return(
        "blah blah metric1 blah\n",
        "here's something for metric2",
        "another line for metric1\n"
      )
      expect(parser).to receive(:metric_matchers).at_least(:once).and_return({
        metric1: proc { |line| line.include?('metric1') },
        metric2: proc { |line| line.include?('metric2') }
      })

      parser.send(:initialize)
      data = parser.collect
      expect(data[:metric1]).to eq(2)
      expect(data[:metric2]).to eq(1)
    end
  end

  describe '#filenames' do
    it 'raises an exception' do
      expect { described_class.allocate.send(:filenames) }.to raise_error(RuntimeError)
    end
  end

  describe '#metric_matchers' do
    it 'raises an exception' do
      expect { described_class.allocate.send(:metric_matchers) }.to raise_error(RuntimeError)
    end
  end
end
