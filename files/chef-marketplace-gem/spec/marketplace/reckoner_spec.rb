require 'spec_helper'
require 'marketplace/reckoner'
require 'marketplace/reckoner/updater/ec2'
require 'marketplace/reckoner/checker/chef_server'

describe Marketplace::Reckoner do
  subject { described_class.new }

  let(:updater) { double('Updater', update: true) }
  let(:checker) { double('Checker', current_usage: 666) }

  before do
    Marketplace::Reckoner::Config['checker']['driver'] = 'chef_server'
    Marketplace::Reckoner::Config['updater']['driver'] = 'ec2'

    allow(Marketplace::Reckoner::Checker::ChefServer).to receive(:new).and_return(checker)
    allow(Marketplace::Reckoner::Updater::Ec2).to receive(:new).and_return(updater)
  end

  describe '#self.update_usage' do
    it 'builds an instance and updates usage' do
      expect(updater).to receive(:update).with(666)
      Marketplace::Reckoner.update_usage
    end
  end

  describe '#update_usage' do
    it 'checks usage and updates the usage' do
      expect(updater).to receive(:update).with(666)
      subject.update_usage
    end
  end
end
